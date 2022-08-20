defmodule Overbooked.Repo.Migrations.AddResourceColor do
  use Ecto.Migration

  def up do
    alter table(:resources) do
      add :color, :string
    end
  end

  def down do
    alter table(:resources) do
      remove :color
    end
  end
end
