defmodule Overbooked.Repo.Migrations.AddResourceType do
  use Ecto.Migration

  def up do
    create table(:resource_types) do
      add :name, :string

      timestamps()
    end

    create unique_index(:resource_types, [:name])

    alter table(:resources) do
      add :resource_type_id, references(:resource_types, on_delete: :delete_all)
    end
  end

  def down do
    drop table(:resource_types)

    alter table(:resources) do
      remove :resource_type
    end

    drop unique_index(:resource_types, [:name])
  end
end
