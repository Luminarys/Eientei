defmodule Eientei.PageView do
  use Eientei.Web, :view

  @service_name Application.get_env(:eientei, :service_name)
  @service_url Application.get_env(:eientei, :service_url)
  @max_upload_size Application.get_env(:eientei, :max_upload_size)
  @use_ia Application.get_env(:eientei, :use_ia_archive)
  @ia_service_name Application.get_env(:eientei, :ia_service_name)

  def service_name, do: @service_name
  def service_url, do: @service_url
  def max_upload_size, do: @max_upload_size
  def use_ia, do: @use_ia
  def ia_service_name, do: @ia_service_name
end
