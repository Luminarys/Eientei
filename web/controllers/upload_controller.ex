defmodule Eientei.UploadController do
  use Eientei.Web, :controller

  @max_file_size Application.get_env(:eientei, :max_file_size)
  @max_cache_size Application.get_env(:eientei, :max_cache_size)
  @use_ia Application.get_env(:eientei, :use_ia_archive)

  @service_url Application.get_env(:eientei, :service_url)

  @illegal_exts [".ade", ".adp", ".bat", ".chm", ".cmd", ".com", ".cpl", ".exe", ".hta", ".ins", ".isp", ".jse", ".lib", ".lnk", ".mde", ".msc", ".msp", ".mst", ".pif", ".scr", ".sct", ".shb", ".sys", ".vb", ".vbe", ".vbs", ".vxd", ".wsc", ".wsf", ".wsh"]
  @name_len 6

  def upload(conn, %{"file" => file}) when is_list(file) do
    json conn, failure("You can only send individual files using the file param!")
  end
  def upload(conn, %{"file" => file}) do
    json conn, %{"file" => upload_file({file, conn})}
  end

  def upload(conn, %{"files" => files}) when is_list(files) do
    cfiles = Enum.map(files, &({&1, conn}))
    json conn, %{"files" => Enum.map(cfiles, &upload_file/1)}
  end
  def upload(conn, %{"files" => _files}) do
    json conn, failure("You can only send a list of files with the files param!")
  end

  def upload(conn, _params) do
    put_status conn, 400
    json conn, failure("Please send files using the file or files key!")
  end

  defp failure(reason), do: %{"success" => false, "reason" => reason}
  defp file_success(name, old_name), do: %{"url" => "#{@service_url}/f/#{name}", "name" => old_name, "success" => true}
  defp file_failure(name, reason), do: %{"name" => name, "success" => false, "reason" => reason}

  @doc """
  Perform size, rate, and file type checks, on a file,
  then generates an unused file name, moves the file,
  and commits the transaction to the database.
  """
  defp upload_file({file, conn}) do
    res = check_file({file, conn})
    case res do
      %{"success" => false} -> res
      file ->
        file
        |> gen_name
        |> move_file
        |> generate_db_entry
    end
  end

  defp check_file({file, conn}) do
    use Pipe
    Pipe.pipe_matching val, {:ok, val},
    file
    |> check_file_size
    |> check_magic_number
    |> check_data_rate(conn)
  end

  defp check_file_size(file) do
    %{size: size} = File.stat! file.path
    case size > @max_file_size * 1000 * 1000 do
      false -> {:ok, file}
      true -> file_failure file.filename, "File too big!"
    end
  end

  defp check_magic_number(file) do
    b = get_init_bytes(file.path)
    case is_exe(b) do
      false -> {:ok, file}
      true -> file_failure file.filename, "Exe's are not allowed!"
    end
  end

  defp get_init_bytes(path) do
    path
    |> File.stream!
    |> Enum.take(1)
    |> hd
  end

  defp is_exe(<<77::8, 90::8, _rest::binary>>), do: true
  defp is_exe(_data), do: false

  defp check_data_rate(file, conn) do
    %{size: size} = File.stat! file.path
    case Eientei.RateLimit.check_data_rate(conn, div(size, (1000 * 1000))) do
      :ok -> {:ok, file}
      :rate_exceeded -> file_failure file.filename, "You have exceeded the maximum rate of data uploaded"
    end
  end

  defp gen_name(file) do
    name = get_rand_chars(@name_len)
    loc = "files/" <> name
    case File.exists?(loc) do
      true -> gen_name(file)
      false -> check_db_names(file, name)
    end
  end

  defp check_db_names(file, name) do
    case Eientei.Repo.get_by(Eientei.Upload, name: name) do
      nil -> {file, name}
      _ -> gen_name(file)
    end
  end

  defp get_rand_chars(length) do
    :crypto.rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end

  defp move_file({file, new_name}) do
    path = file.path
    old_name = file.filename
    name = new_name <> Path.extname(old_name)
    new_path = "files/" <> name
    # Move file, since Elixir seems to not provide an equivalent
    System.cmd("mv", [path, new_path])
    {name, new_path, old_name}
  end

  defp generate_db_entry({name, loc, orig_name}) do
    r = File.read! loc
    hash = md5(r)
    Task.start(fn -> update_cache(name, r) end)
    %{size: size} = File.stat! loc
    new_loc = remove_duplicate_file(hash, loc)
    add_db_entry(name, new_loc, hash, orig_name, size)
  end

  defp md5(data) do
    :erlang.md5(data)
    |> :erlang.bitstring_to_list
    |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
    |> List.flatten
    |> :erlang.list_to_bitstring
  end

  defp update_cache(file, name) do
    ets = ConCache.ets(:file_cache)
    size = :ets.info(ets) |> Keyword.get(:size)
    if size >= @max_cache_size do
      # High quality algorithms right here
      :random.seed(:os.timestamp)
      {item, _} = Enum.random(ets |> :ets.tab2list)
      ConCache.delete(:file_cache, item)
    end
    ConCache.put(:file_cache, name, file)
  end

  defp remove_duplicate_file(hash, location) do
    import Ecto.Query, only: [from: 2]
    query = from u in Eientei.Upload,
        where: u.hash == ^hash,
        select: u.location,
        limit: 1
    case Eientei.Repo.one(query) do
      nil -> location
      existing_location ->
        File.rm! location
        existing_location
    end
  end

  defp add_db_entry(full_name, location, hash, orig_name, size) do
    changeset = Eientei.Upload.changeset(%Eientei.Upload{}, %{:name => full_name, :location => location, :hash => hash, :filename => orig_name, :size => size})
    {:ok, _user} = Eientei.Repo.insert(changeset)
    file_success full_name, orig_name
  end
end
