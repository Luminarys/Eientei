defmodule Eientei.Repo.CreateTables do
  use Ecto.Migration

  def up do
    create table(:uploads) do
      add :name, :string
      add :location, :string
      add :hash, :string
      add :filename, :string
      add :size, :integer
      add :archived_url, :string
      timestamps
    end
    create index(:uploads, [:name, :location, :hash, :archived_url], unique: true)
  end

  def down do
    drop index(:uploads, [:name, :location, :hash, :archived_url], unique: true)
    drop table(:uploads)
end
