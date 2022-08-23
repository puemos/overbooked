defmodule Overbooked.ScheduleTest do
  use Overbooked.DataCase

  alias Overbooked.Schedule
  alias Overbooked.Schedule.Booking

  import Overbooked.ScheduleFixtures
  import Overbooked.ResourcesFixtures
  import Overbooked.AccountsFixtures

  describe "bookings" do
    test "book_resource/3 book a resource" do
      resource = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = booking} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })

      assert booking.end_at == ~U[2022-08-14 01:00:00Z]
    end

    test "book_resource/3 can't book a busy resource" do
      resource = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = _booking} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })

      assert {:ok, %Booking{} = _booking} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 01:00:00Z],
                 end_at: ~U[2022-08-14 01:10:00Z]
               })

      assert {:error, :resource_busy} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:30:00Z],
                 end_at: ~U[2022-08-14 00:45:00Z]
               })

      assert {:error, :resource_busy} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 00:45:00Z]
               })

      assert {:error, :resource_busy} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 01:10:00Z]
               })

      assert {:error, :resource_busy} =
               Schedule.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })
    end

    test "book_resource/3 should allow to book a free resource in the same time of busy resource" do
      resource_1 = resource_fixture()
      resource_2 = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = _booking} =
               Schedule.book_resource(resource_1, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })

      assert {:ok, %Booking{} = _booking} =
               Schedule.book_resource(resource_2, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })
    end
  end

  describe "list bookings" do
    test "list_bookings/2 should get all bookings by time range" do
      resource_1 = resource_fixture()
      resource_2 = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{id: booking_1}} =
               Schedule.book_resource(resource_1, user, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert {:ok, %Booking{id: booking_2}} =
               Schedule.book_resource(resource_1, user, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 00:20:00Z]
               })

      assert {:ok, %Booking{id: booking_3}} =
               Schedule.book_resource(resource_2, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 00:30:00Z]
               })

      assert [%Booking{id: ^booking_2}, %Booking{id: ^booking_3}] =
               Schedule.list_bookings(~U[2022-08-14 00:11:00Z], ~U[2022-08-14 00:29:00Z])

      assert [%Booking{id: ^booking_1}, %Booking{id: ^booking_2}, %Booking{id: ^booking_3}] =
               Schedule.list_bookings(~U[2022-08-14 00:00:00Z], ~U[2022-08-14 00:20:00Z])
    end

    test "list_bookings/2 get bookings by resource" do
      resource_1 = resource_fixture()
      resource_2 = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{id: _booking_1}} =
               Schedule.book_resource(resource_1, user, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert {:ok, %Booking{id: booking_2}} =
               Schedule.book_resource(resource_2, user, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 00:20:00Z]
               })

      assert {:ok, %Booking{id: booking_3}} =
               Schedule.book_resource(resource_2, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 00:30:00Z]
               })

      assert [%Booking{id: ^booking_2}, %Booking{id: ^booking_3}] =
               Schedule.list_bookings(
                 ~U[2022-08-14 00:00:00Z],
                 ~U[2022-08-14 00:20:00Z],
                 resource_2
               )
    end
  end

  describe "modifing bookings" do
    test "delete_booking/2 delete a booking" do
      resource_1 = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = booking_1} =
               Schedule.book_resource(resource_1, user, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert {:ok, %Booking{id: _booking_1}} = Schedule.delete_booking(booking_1, user)
    end

    test "delete_booking/2 can't delete someone's else booking" do
      resource_1 = resource_fixture()
      user_1 = user_fixture()
      user_2 = user_fixture()

      assert {:ok, %Booking{} = booking_1} =
               Schedule.book_resource(resource_1, user_1, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert_raise FunctionClauseError, fn ->
        Schedule.delete_booking(booking_1, user_2)
      end
    end

    test "update_booking/3 update a booking" do
      resource_1 = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = booking_1} =
               Schedule.book_resource(resource_1, user, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert {:ok, %Booking{start_at: ~U[2022-08-14 00:05:00Z]}} =
               Schedule.update_booking(booking_1, resource_1, user, %{
                 start_at: ~U[2022-08-14 00:05:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })
    end

    test "update_booking/3 can't update a booking to a busy time" do
      resource_1 = resource_fixture()
      user_1 = user_fixture()

      assert {:ok, %Booking{} = booking_1} =
               Schedule.book_resource(resource_1, user_1, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert {:ok, %Booking{} = _booking_2} =
               Schedule.book_resource(resource_1, user_1, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 00:20:00Z]
               })

      assert {:error, :resource_busy} =
               Schedule.update_booking(booking_1, resource_1, user_1, %{
                 start_at: ~U[2022-08-14 00:15:00Z],
                 end_at: ~U[2022-08-14 00:17:00Z]
               })
    end

    test "update_booking/3 can't update someone's else booking" do
      resource_1 = resource_fixture()
      user_1 = user_fixture()
      user_2 = user_fixture()

      assert {:ok, %Booking{} = booking_1} =
               Schedule.book_resource(resource_1, user_1, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 00:10:00Z]
               })

      assert_raise FunctionClauseError, fn ->
        Schedule.update_booking(booking_1, resource_1, user_2, %{
          start_at: ~U[2022-08-14 00:05:00Z],
          end_at: ~U[2022-08-14 00:10:00Z]
        })
      end
    end
  end
end
