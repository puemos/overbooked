defmodule Overbooked.Repo.Migrations.CreateResuorceAmenities do
  use Ecto.Migration

  def change do
    create table(:resuorce_amenities) do
      add :resource_id, references(:resources, on_delete: :nothing)
      add :amenity_id, references(:amenities, on_delete: :nothing)

      timestamps()
    end

    create index(:resuorce_amenities, [:resource_id])
    create index(:resuorce_amenities, [:amenity_id])
  end
end
