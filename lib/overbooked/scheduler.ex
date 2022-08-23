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

  def booking_groups(bookings, :hourly) do
    bookings
    |> Enum.map(fn b ->
      Timex.Interval.new(from: b.start_at, until: b.end_at, step: [minutes: 15])
      |> Enum.map(fn d -> {d, b} end)
    end)
    |> List.flatten()
    |> Enum.group_by(fn {d, _} -> Timex.day(d) end)
    |> Enum.map(fn {d, slots} ->
      slots =
        slots
        |> Enum.sort_by(fn {_d, b} -> Map.fetch!(b, :id) end)
        |> Enum.group_by(
          fn {d, _} ->
            Timex.format!(d, "%H:%M", :strftime)
          end,
          fn {_, b} ->
            b
          end
        )

      {d, slots}
    end)
    |> Enum.map(fn {d, slots} -> Map.put(%{}, d, slots) end)
    |> Enum.reduce(%{}, fn slots, map ->
      Map.merge(slots, map, fn _k, v1, v2 -> v2 ++ v1 end)
    end)
  end

  def booking_groups(bookings, :daily) do
    bookings
    |> Enum.map(fn b ->
      Timex.Interval.new(from: b.start_at, until: b.end_at, step: [days: 1])
      |> Enum.map(fn i -> {i, b} end)
      |> Enum.group_by(
        fn {i, _b} -> Timex.day(i) end,
        fn {_, b} ->
          b
        end
      )
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn slots, map ->
      Map.merge(slots, map, fn _k, v1, v2 -> v2 ++ v1 end)
    end)
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
