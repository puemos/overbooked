defmodule Overbooked.Repo.Migrations.CreateAmenities do
  use Ecto.Migration

  def change do
    create table(:amenities) do
      add :name, :string

      timestamps()
    end
  end
end
