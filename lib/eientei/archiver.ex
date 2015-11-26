defmodule Eientei.Archiver do
  use GenServer

  @make_bucket {"x-amz-auto-make-bucket", "1"}
  @collection {"x-archive-meta01-collection", "opensource_media"}
  @media_type {"x-archive-meta-mediatype", "web"}
  @ia_sponsor {"x-archive-meta-sponsor", Application.get_env(:einetei, :ia_sponsor)}

  @ia_access Application.get_env(:eientei, :ia_access)
  @ia_secret Application.get_env(:eientei, :ia_secret)
  @ia_auth {"authorization", "LOW #{@ia_access}:#{@ia_secret}"}

  @service Application.get_env(:eientei, :ia_service_name)
  @bucket_name "#{@service}_archive"

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: Archiver)
  end

  def handle_call({:archive, name, location}, _from, state) do
    require Logger
    case archive_file(name, location) do
      :error ->
        Logger.log :warn, "File #{location} could not be uploaded to the IA archive!"
        {:reply, :failed, state}
      :ok ->
        update_model(name)
        {:reply, :ok, state}
    end
  end

  def handle_cast({:archive, name, location}, state) do
    require Logger
    case archive_file(name, location) do
      :error ->
        Logger.log :warn, "File #{location} could not be uploaded to the IA archive!"
        {:noreply, state}
      :ok ->
        update_model(name)
        {:noreply, state}
    end
  end

  defp update_model(name) do
    import Ecto.Query

    query = from u in Eientei.Upload,
        where: u.name == ^name
    file = Eientei.Repo.one query
    {:ok, _file} = Eientei.Repo.update(%{file | archived_url: "https://archive.org/download/#{@bucket_name}/#{name}"})
  end

  defp archive_file(name, location) do
    check_rate_limit
    access = Application.get_env(:eientei, :ia_access)
    secret = Application.get_env(:eientei, :ia_secret)
    headers = [
      @make_bucket,
      @collection,
      @media_type,
      @ia_sponsor,
      @ia_auth,
    ]
    try do
      {:ok, resp} = HTTPoison.put("http://s3.us.archive.org/#{@bucket_name}/#{name}",
                    {:file, "#{location}"},
                    headers)
      case resp do
        %{status_code: 200} -> :ok
        %{status_code: 400} ->
          # Try sending with no extension
          # If it fails then log an error
          new_name = Path.basename(name, Path.extname(name))
          {:ok, new_resp} = HTTPoison.put("http://s3.us.archive.org/#{@bucket_name}/#{new_name}",
                    {:file, "#{location}"},
                    headers)
          case new_resp do
            %{status_code: 200} -> :ok
            %{status_code: 400} -> :error
          end
      end
    rescue
      MatchError ->
        # Catches timeout errors
        GenServer.cast(Archiver, {:archive, name, location})
        :ok
    end
  end

  defp check_rate_limit() do
    {:ok, %{:body => body}} = HTTPoison.get("http://s3.us.archive.org/?check_limit=1&bucket=#{@bucket_name}&accesskey=#{@ia_access}")
    %{"over_limit" => over_limit} = body |> Poison.decode!
    case over_limit do
      0 -> :ok
      1 ->
        :timer.sleep(10000)
        check_rate_limit
    end
  end
end
