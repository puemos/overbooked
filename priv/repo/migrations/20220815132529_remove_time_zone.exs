defmodule Overbooked.Repo.Migrations.RemoveTimeZone do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      remove :time_zone
    end
  end
end
