defmodule Eientei.Repo do
  use Ecto.Repo, otp_app: :eientei
end

defmodule Upload do
  @moduledoc """
  Represents a file in the database.
  """
  use Ecto.Model
  schema "uploads" do
    field :name, :string
    field :location, :string
    field :hash, :string
    field :filename, :string
    field :size, :integer
    field :archived_url, :string
    timestamps
  end
end
