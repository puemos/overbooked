defmodule Overbooked.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string
    has_many :bookings, Overbooked.Scheduler.Booking
    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
