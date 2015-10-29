defmodule Eientei.Archiver do
  use GenServer

  @make_bucket {"x-amz-auto-make-bucket", "1"}
  @collection {"x-archive-meta01-collection", "opensource"}
  @media_type {"x-archive-meta-mediatype", "web"}
  @service Application.get_env(:eientei, :ia_service_name)

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
    {:ok, _file} = Eientei.Repo.update(%{file | archived_url: "https://archive.org/download/#{@service}_archive/#{name}"})
  end

  defp archive_file(name, location) do
    access = Application.get_env(:eientei, :ia_access)
    secret = Application.get_env(:eientei, :ia_secret)
    headers = [
      @make_bucket,
      @collection,
      @media_type,
      {"x-archive-meta-sponsor", Application.get_env(:einetei, :ia_sponsor)},
      {"authorization", "LOW #{access}:#{secret}"}
    ]
    try do
      {:ok, resp} = HTTPoison.put("http://s3.us.archive.org/#{@service}_archive/#{name}",
                    {:file, "#{location}"},
                    headers)
      case resp do
        %{status_code: 200} -> :ok
        %{status_code: 400} ->
          # Try sending with no extension
          # If it fails then log an error
          new_name = Path.basename(name, Path.extension(name))
          {:ok, new_resp} = HTTPoison.put("http://s3.us.archive.org/#{@service}_archive/#{new_name}",
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
end

defmodule Mix.Tasks.Archive.Files do
  use Mix.Task

  def run(_) do
    import Ecto.Query

    Mix.shell.info "Uploading all unarchived files!"
    Mix.Tasks.App.Start.run([])
    # start
    query = from u in Eientei.Upload,
        select: {u.name, u.location},
        where: is_nil u.archived_url
    res = Eientei.Repo.all query
    for {name, location} <- res, do: GenServer.call(Archiver, {:archive, name, location}, 500000)
    Mix.shell.info "Done!"
  end
end
