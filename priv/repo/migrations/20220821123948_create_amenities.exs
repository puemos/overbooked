defmodule Overbooked.Repo.Migrations.CreateAmenities do
  use Ecto.Migration

  def change do
    create table(:amenities) do
      add :name, :string
      add :count, :integer

      timestamps()
    end
  end
end
