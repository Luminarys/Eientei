defmodule Eientei.SharedView do
  use Eientei.Web, :view

  defp git_repo_url, do: Application.get_env(:eientei, :git_repo_url)
end
