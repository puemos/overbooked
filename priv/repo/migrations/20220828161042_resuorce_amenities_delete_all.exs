defmodule Overbooked.Repo.Migrations.ResuorceAmenitiesDeleteAll do
  use Ecto.Migration

  def up do
    drop(constraint(:resuorce_amenities, "resuorce_amenities_resource_id_fkey"))

    alter table(:resuorce_amenities) do
      modify(:resource_id, references(:resources, on_delete: :delete_all))
    end
  end

  def down do
    drop(constraint(:resuorce_amenities, "resuorce_amenities_resource_id_fkey"))

    alter table(:resuorce_amenities) do
      modify(:resource_id, references(:resources, on_delete: :nothing))
    end
  end
end
