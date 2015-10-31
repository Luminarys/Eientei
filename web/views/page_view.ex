defmodule Eientei.PageView do
  use Eientei.Web, :view

  defp service_name, do: Application.get_env(:eientei, :service_name)
  defp service_domain, do:  Application.get_env(:eientei, :service_domain)
  defp contact_email, do:  Application.get_env(:eientei, :contact_email)
  defp max_upload_size, do:  Application.get_env(:eientei, :max_upload_size)
  defp max_file_size, do:  Application.get_env(:eientei, :max_file_size)

  defp use_ia, do: Application.get_env(:eientei, :use_ia_archive)
  defp ia_service_name, do: Application.get_env(:eientei, :ia_service_name)

  defp fallback_alert, do: Application.get_env(:eientei, :fallback_service_alert)
  defp fallback_homepage, do: Application.get_env(:eientei, :fallback_service_home_page)

  def get_total_file_size do
    import Ecto.Query, only: [from: 2]
    size_query = from u in Eientei.Upload,
        distinct: u.location,
        select: u.size
    sizes = Eientei.Repo.all(size_query)
    Float.floor(Enum.reduce(sizes, 0, &(&1/(1000*1000) + &2)), 1)
  end

  def get_file_count do
    import Ecto.Query, only: [from: 2]
    count_query = from u in Eientei.Upload,
                  select: count(u.id)
    Eientei.Repo.one(count_query)
  end
end
