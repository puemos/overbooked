defmodule Overbooked.Scheduler do
  @moduledoc """
  The Scheduler context.
  """

  import Ecto.Query, warn: false
  alias Overbooked.Repo

  alias Overbooked.Scheduler.Booking
  alias Overbooked.Resources.Resource
  alias Overbooked.Accounts.User

  def resource_busy?(%Resource{} = resource, start_at, end_at) do
    from(b in Booking,
      where: b.resource_id == ^resource.id,
      where:
        (^start_at >= b.start_at and ^start_at < b.end_at) or
          (^end_at > b.start_at and ^end_at <= b.end_at)
    )
    |> Repo.exists?()
  end

  def resource_busy?(%Resource{} = resource, start_at, end_at, booking) do
    from(b in Booking,
      where: b.resource_id == ^resource.id,
      where:
        (^start_at >= b.start_at and ^start_at < b.end_at) or
          (^end_at > b.start_at and ^end_at <= b.end_at),
      where: b.id != ^booking.id
    )
    |> Repo.exists?()
  end

  def book_resource(%Resource{} = resource, %User{} = user, attrs \\ %{}) do
    end_at = attrs["end_at"] || attrs[:end_at]
    start_at = attrs["start_at"] || attrs[:start_at]

    if resource_busy?(resource, start_at, end_at) do
      {:error, :resource_busy}
    else
      %Booking{}
      |> Booking.changeset(attrs)
      |> Booking.put_resource(resource)
      |> Booking.put_user(user)
      |> Repo.insert()
    end
  end

  def list_bookings(start_at, end_at) do
    from(b in Booking,
      where: ^start_at <= b.end_at and b.start_at <= ^end_at,
      order_by: b.start_at,
      preload: [resource: [:resource_type], user: []]
    )
    |> Repo.all()
  end

  def list_bookings(start_at, end_at, %Resource{} = resource) do
    from(b in Booking,
      where: b.resource_id == ^resource.id,
      where: ^start_at <= b.end_at and b.start_at <= ^end_at,
      order_by: b.start_at,
      preload: [resource: [:resource_type], user: []]
    )
    |> Repo.all()
  end

  def list_bookings(start_at, end_at, %User{} = user) do
    from(b in Booking,
      where: b.user_id == ^user.id,
      where: ^start_at <= b.end_at and b.start_at <= ^end_at,
      order_by: b.start_at,
      preload: [resource: [:resource_type], user: []]
    )
    |> Repo.all()
  end

  def get_booking!(id), do: Repo.get!(Booking, id)

  def update_booking(
        %Booking{user_id: user_id} = booking,
        %Resource{} = resource,
        %User{id: user_id},
        attrs
      ) do
    if resource_busy?(resource, attrs[:start_at], attrs[:end_at], booking) do
      {:error, :resource_busy}
    else
      booking
      |> Booking.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_booking(%Booking{user_id: user_id} = booking, %User{id: user_id}) do
    Repo.delete(booking)
  end

  def change_booking(%Booking{} = booking, attrs \\ %{}) do
    Booking.changeset(booking, attrs)
  end
end
