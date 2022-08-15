defmodule Overbooked.SchedulerTest do
  use Overbooked.DataCase

  alias Overbooked.Scheduler

  describe "bookings" do
    alias Overbooked.Scheduler.Booking
    alias Overbooked.Resources.Resource

    import Overbooked.SchedulerFixtures
    import Overbooked.ResourcesFixtures
    import Overbooked.AccountsFixtures

    test "book_resource/3 book a resource" do
      resource = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = booking} =
               Scheduler.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:00:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })

      assert booking.end_at == ~U[2022-08-14 01:00:00Z]
    end

    test "book_resource/3 can't book a resource if it's unavaliable" do
      resource = resource_fixture()
      user = user_fixture()

      assert {:ok, %Booking{} = _booking} =
               Scheduler.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })

      assert {:error, :resource_busy} =
               Scheduler.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:30:00Z],
                 end_at: ~U[2022-08-14 00:45:00Z]
               })

      assert {:error, :resource_busy} =
               Scheduler.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 00:45:00Z]
               })

      assert {:error, :resource_busy} =
               Scheduler.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:10:00Z],
                 end_at: ~U[2022-08-14 01:10:00Z]
               })

      assert {:error, :resource_busy} =
               Scheduler.book_resource(resource, user, %{
                 start_at: ~U[2022-08-14 00:20:00Z],
                 end_at: ~U[2022-08-14 01:00:00Z]
               })
    end
  end
end
