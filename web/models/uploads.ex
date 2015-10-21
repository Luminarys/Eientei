defmodule Eientei.Upload do
  use Eientei.Web, :model

  schema "uploads" do
    field :name, :string
    field :location, :string
    field :hash, :string
    field :filename, :string
    field :size, :integer
    field :archived_url, :string

    timestamps
  end

  @required_fields ~w(name location hash filename size)
  @optional_fields ~w(archived_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
