defmodule Eientei.SharedView do
  use Eientei.Web, :view

  @git_repo_url Application.get_env(:eientei, :git_repo_url)

  def git_repo_url, do: @git_repo_url

end
