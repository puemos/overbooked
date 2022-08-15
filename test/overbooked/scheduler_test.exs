defmodule Overbooked.SchedulerTest do
  use Overbooked.DataCase

  alias Overbooked.Scheduler

  describe "bookings" do
    alias Overbooked.Scheduler.Booking

    import Overbooked.SchedulerFixtures

    @invalid_attrs %{end_at: nil, start_at: nil, time_zone: nil}

    test "list_bookings/0 returns all bookings" do
      booking = booking_fixture()
      assert Scheduler.list_bookings() == [booking]
    end

    test "get_booking!/1 returns the booking with given id" do
      booking = booking_fixture()
      assert Scheduler.get_booking!(booking.id) == booking
    end

    test "create_booking/1 with valid data creates a booking" do
      valid_attrs = %{
        end_at: ~U[2022-08-14 08:43:00Z],
        start_at: ~U[2022-08-14 08:43:00Z],
        time_zone: "some time_zone"
      }

      assert {:ok, %Booking{} = booking} = Scheduler.create_booking(valid_attrs)
      assert booking.end_at == ~U[2022-08-14 08:43:00Z]
      assert booking.start_at == ~U[2022-08-14 08:43:00Z]
      assert booking.time_zone == "some time_zone"
    end

    test "create_booking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_booking(@invalid_attrs)
    end

    test "update_booking/2 with valid data updates the booking" do
      booking = booking_fixture()

      update_attrs = %{
        end_at: ~U[2022-08-15 08:43:00Z],
        start_at: ~U[2022-08-15 08:43:00Z],
        time_zone: "some updated time_zone"
      }

      assert {:ok, %Booking{} = booking} = Scheduler.update_booking(booking, update_attrs)
      assert booking.end_at == ~U[2022-08-15 08:43:00Z]
      assert booking.start_at == ~U[2022-08-15 08:43:00Z]
      assert booking.time_zone == "some updated time_zone"
    end

    test "update_booking/2 with invalid data returns error changeset" do
      booking = booking_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_booking(booking, @invalid_attrs)
      assert booking == Scheduler.get_booking!(booking.id)
    end

    test "delete_booking/1 deletes the booking" do
      booking = booking_fixture()
      assert {:ok, %Booking{}} = Scheduler.delete_booking(booking)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_booking!(booking.id) end
    end

    test "change_booking/1 returns a booking changeset" do
      booking = booking_fixture()
      assert %Ecto.Changeset{} = Scheduler.change_booking(booking)
    end
  end
end
