defmodule Overbooked.Schedule.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :end_at, :utc_datetime
    field :start_at, :utc_datetime
    belongs_to :resource, Overbooked.Resources.Resource
    belongs_to :user, Overbooked.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:end_at, :start_at])
    |> validate_required([:end_at, :start_at])
  end

  def put_user(%Ecto.Changeset{} = changeset, %Overbooked.Accounts.User{} = user) do
    put_assoc(changeset, :user, user)
  end

  def put_resource(%Ecto.Changeset{} = changeset, %Overbooked.Resources.Resource{} = resource) do
    put_assoc(changeset, :resource, resource)
  end
end
