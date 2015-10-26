defmodule Eientei.UploadController do
  use Eientei.Web, :controller

  @max_upload_size Application.get_env(:eientei, :max_upload_size)
  @use_ia Application.get_env(:eientei, :use_ia_archive)

  @illegal_exts [".ade", ".adp", ".bat", ".chm", ".cmd", ".com", ".cpl", ".exe", ".hta", ".ins", ".isp", ".jse", ".lib", ".lnk", ".mde", ".msc", ".msp", ".mst", ".pif", ".scr", ".sct", ".shb", ".sys", ".vb", ".vbe", ".vbs", ".vxd", ".wsc", ".wsf", ".wsh"]

  def upload(conn, %{"file" => file}) do
    # Randomly generate unused file name
    # Return filename as url, queue an async check
    # Check hashes file, sees if hash is in db
    # and modifies file location if necessary,
    # removing any duplicates
    use Pipe

    name_len = 6

    resp = Pipe.pipe_matching val, {:ok, val},
    {:ok, file}
    |> check_magic_number
    |> gen_name(name_len)
    |> move_file
    |> generate_db_entry

    json conn, resp
  end

  defp success(name), do: %{"url" => "/f/#{name}", "name" => name, "success" => true}
  defp failure(reason), do: %{"url" => "/", "success" => false, "reason" => reason}

  defp check_magic_number(file) do
    case is_exe(hd(Enum.take(File.stream!(file.path),1))) do
      false -> {:ok, file}
      true -> failure "Exe's are not allowed!"
    end
  end

  defp gen_name(file, length) do
    name = :crypto.rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    loc = "files/" <> name
    case File.exists?(loc) do
      true -> gen_name(file, length)
      false ->
        case Eientei.Repo.get_by(Eientei.Upload, name: name) do
          nil -> {:ok, {file, name}}
          _ -> gen_name(file, length)
        end
    end
  end

  defp move_file({file, new_name}) do
    path = file.path
    old_name = file.filename
    name = new_name <> Path.extname(old_name)
    new_path = "files/" <> name
    # Move file, since Elixir seems to not provide an equivalent
    System.cmd("mv", [path, new_path])
    {:ok, {file, new_name, name, new_path, old_name}}
  end

  defp generate_db_entry({_file, name, full_name, loc, orig_name}) do
    import Ecto.Query, only: [from: 2]
    r = File.read! loc
    ConCache.put(:file_cache, full_name, r)
    hash = md5(r)
    # Perhaps find a better place to do this
    Task.start(fn -> ConCache.put(:file_cache, full_name, r) end)
    %{size: size} = File.stat! loc

    query = from u in Eientei.Upload,
        where: u.hash == ^hash,
        select: u.location,
        limit: 1

    case Eientei.Repo.one(query) do
      nil -> 
        changeset = Eientei.Upload.changeset(%Eientei.Upload{}, %{:name => name, :location => loc, :hash => hash, :filename => orig_name, :size => size})
        {:ok, _user} = Eientei.Repo.insert(changeset)
        success full_name
      location ->
        File.rm! loc
        changeset = Eientei.Upload.changeset(%Eientei.Upload{}, %{:name => name, :location => location, :hash => hash, :filename => orig_name, :size => size})
        {:ok, _user} = Eientei.Repo.insert(changeset)
        success full_name
    end
  end

  defp md5(data) do
    :erlang.md5(data)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
  end

  defp is_exe(<<77::8, 90::8, _rest::binary>>), do: true
  defp is_exe(_data), do: false
end
