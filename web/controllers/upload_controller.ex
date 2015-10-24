defmodule Eientei.UploadController do
  use Eientei.Web, :controller

  @max_upload_size Application.get_env(:eientei, :max_upload_size)
  @use_ia Application.get_env(:eientei, :use_ia_archive)
  @file_access_url Application.get_env(:eientei, :file_access_url)

  @illegal_exts [".ade", ".adp", ".bat", ".chm", ".cmd", ".com", ".cpl", ".exe", ".hta", ".ins", ".isp", ".jse", ".lib", ".lnk", ".mde", ".msc", ".msp", ".mst", ".pif", ".scr", ".sct", ".shb", ".sys", ".vb", ".vbe", ".vbs", ".vxd", ".wsc", ".wsf", ".wsh"]

  def upload(conn, %{"file" => file}) do
    # Randomly generate unused file name
    # Return filename as url, queue an async check
    # Check hashes file, sees if hash is in db
    # and modifies file location if necessary,
    # removing any duplicates
    name_len = 6
    # TODO: Write a magic number => MIME checking library
    case Enum.member? @illegal_exts, Path.extname(file.filename) do
      false ->
        %{size: size} = File.stat! file.path
        if size/(1000*1000) <= @max_upload_size do
          name = name_len 
          |> gen_name 
          |> move_file(file.path, file.filename)

          # json = %{"url" => url, "shorthash" => shash, "hash" => hash, "success" => success}
          json_resp = %{"url" => "#{@file_access_url}/#{name}", "name" => name, "success" => true}
          json conn, json_resp
        else
          json_resp = %{"url" => "/", "success" => false}
          json conn, json_resp
        end
      true ->
        json_resp = %{"url" => "/", "success" => false}
        json conn, json_resp
    end
  end

  defp gen_name(length) do
    name = :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
    loc = "files/" <> name
    case File.exists?(loc) do
      true -> gen_name(length)
      false ->
        case Eientei.Repo.get_by(Eientei.Upload, name: name) do
          nil -> name
          _ -> gen_name(length)
        end
    end
  end

  defp move_file(new_name, path, old_name) do
    name = new_name <> Path.extname(old_name)
    new_path = "files/" <> name
    # Move file, since Elixir seems to not provide an equivalent
    System.cmd("mv", [path, new_path])
    {:ok, location} = generate_db_entry(name, new_path, old_name)
    # Start async archive process
    case @use_ia do
      true -> 
        GenServer.cast(Archiver, {:archive, name, location})
        name
      false -> name
    end
  end

  defp generate_db_entry(name, loc, orig_name) do
    import Ecto.Query, only: [from: 2]
    hash = md5(File.read! loc)
    %{size: size} = File.stat! loc

    query = from u in Eientei.Upload,
        where: u.hash == ^hash,
        select: u.location,
        limit: 1

    case Eientei.Repo.one(query) do
      nil -> 
        changeset = Eientei.Upload.changeset(%Eientei.Upload{}, %{:name => name, :location => loc, :hash => hash, :filename => orig_name, :size => size})
        {:ok, _user} = Eientei.Repo.insert(changeset)
        {:ok, loc}
      location ->
        File.rm! loc
        changeset = Eientei.Upload.changeset(%Eientei.Upload{}, %{:name => name, :location => location, :hash => hash, :filename => orig_name, :size => size})
        {:ok, _user} = Eientei.Repo.insert(changeset)
        {:ok, location}
    end
  end

  defp md5(data) do
    :erlang.md5(data)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
  end
end
