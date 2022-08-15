defmodule Overbooked.Scheduler.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :end_at, :utc_datetime
    field :start_at, :utc_datetime
    field :time_zone, :string
    belongs_to :resource, Overbooked.Resources.Resource

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:end_at, :start_at, :time_zone])
    |> validate_required([:end_at, :start_at, :time_zone])
  end
end
