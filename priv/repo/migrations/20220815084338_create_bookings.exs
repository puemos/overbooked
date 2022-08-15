defmodule Overbooked.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :end_at, :utc_datetime
      add :start_at, :utc_datetime
      add :time_zone, :string
      add :resource_id, references(:resources, on_delete: :nothing)

      timestamps()
    end

    create index(:bookings, [:resource_id])
  end
end
