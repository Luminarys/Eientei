
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
