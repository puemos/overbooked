defmodule Overbooked.Repo.Migrations.AddUserToBookings do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:bookings, [:user_id])
  end
end
