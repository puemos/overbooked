defmodule Overbooked.SchedulerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Overbooked.Scheduler` context.
  """

  @doc """
  Generate a booking.
  """
  def booking_fixture(attrs \\ %{}) do
    {:ok, booking} =
      attrs
      |> Enum.into(%{
        end_at: ~U[2022-08-14 08:43:00Z],
        start_at: ~U[2022-08-14 08:43:00Z],
        time_zone: "some time_zone"
      })
      |> Overbooked.Scheduler.create_booking()

    booking
  end
end
