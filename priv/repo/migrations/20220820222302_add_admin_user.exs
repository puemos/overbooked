defmodule Overbooked.Repo.Migrations.AddAdminUser do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :admin, :boolean
    end
  end

  def down do
    alter table(:users) do
      remove :admin
    end
  end
end
