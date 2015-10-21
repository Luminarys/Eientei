defmodule Eientei.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :name, :string
      add :location, :string
      add :hash, :string
      add :filename, :string
      add :size, :integer
      add :archived_url, :string

      timestamps
    end
    create index(:uploads, [:name], unique: true)

  end

  def down do
    drop index(:uploads, [:name], unique: true)
    drop table(:uploads)
  end
end
