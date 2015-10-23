defmodule Eientei.PageView do
  use Eientei.Web, :view

  @service_name Application.get_env(:eientei, :service_name)
  @service_url Application.get_env(:eientei, :service_url)
  @contact_email Application.get_env(:eientei, :contact_email)
  @max_upload_size Application.get_env(:eientei, :max_upload_size)

  @use_ia Application.get_env(:eientei, :use_ia_archive)
  @ia_service_name Application.get_env(:eientei, :ia_service_name)

  @fallback_alert Application.get_env(:eientei, :fallback_service_alert)
  @fallback_homepage Application.get_env(:eientei, :fallback_service_home_page)

  def service_name, do: @service_name
  def service_url, do: @service_url
  def contact_email, do: @contact_email
  def max_upload_size, do: @max_upload_size

  def use_ia, do: @use_ia
  def ia_service_name, do: @ia_service_name

  def fallback_alert, do: @fallback_alert
  def fallback_homepage, do: @fallback_homepage

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
