defmodule Eientei.Archiver do
  use GenServer

  @make_bucket {"x-amz-auto-make-bucket", "1"}
  @collection {"x-archive-meta01-collection", "opensource"}
  @media_type {"x-archive-meta-mediatype", "web"}

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: Archiver)
  end

  def handle_cast({:archive, name, location}, state) do
    access = Application.get_env(:eientei, :ia_access)
    secret = Application.get_env(:eientei, :ia_secret)
    service = Application.get_env(:eientei, :ia_service_name)
    headers = [
      @make_bucket,
      @collection,
      @media_type,
      {"x-archive-meta-sponsor", Application.get_env(:einetei, :ia_sponsor)},
      {"authorization", "LOW #{access}:#{secret}"}
    ]
    try do
      {:ok, resp} = HTTPoison.put("http://s3.us.archive.org/#{service}_archive/#{name}", 
                    {:file, "#{location}"}, 
                    headers)
      case resp do
        %{status_code: 200} -> {:noreply, state}
        %{status_code: 400} -> 
          # Try sending with no extension
          # If it fails then log an error
          new_name = Path.basename(name, Path.extension(name))
          {:ok, new_resp} = HTTPoison.put("http://s3.us.archive.org/#{service}_archive/#{new_name}", 
                    {:file, "#{location}"}, 
                    headers)
          case new_resp do
            %{status_code: 200} -> {:noreply, state}
            %{status_code: 400} -> 
              require Logger
              Logger.log :warn, "File #{location} could not be uploaded to the IA archive!"
              {:noreply, state}
          end
      end
    rescue
      MatchError ->
        # Catches timeout errors
        GenServer.cast(Archiver, {:archive, name, location})
    end
  end
end
