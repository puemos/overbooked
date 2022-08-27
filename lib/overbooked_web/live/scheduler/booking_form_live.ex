defmodule OverbookedWeb.ScheduleLive.BookingForm do
  use OverbookedWeb, :live_component

  alias Overbooked.Resources
  alias Overbooked.Schedule
  alias Overbooked.Schedule.{Booking}

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.modal id={"#{@id}-modal"} icon={nil}>
        <:title>Book a resource</:title>
        <.form
          :let={f}
          for={@changeset}
          phx-submit={:add_booking}
          phx-change={:validate}
          phx-target={@myself}
          id={"#{@id}-form"}
          class="flex flex-col space-y-4"
        >
          <div class="">
            <label for="start_at" class="block text-sm font-medium text-gray-700">
              Resource
            </label>
            <div class="mt-1">
              <.select
                form={f}
                field={:resource_id}
                name="resource_id"
                phx_debounce="blur"
                options={Enum.map(@resources, &{&1.name, &1.id})}
                required={true}
              />
            </div>
          </div>
          <div class="flex flex-row space-x-4">
            <div class="">
              <label for="start_at" class="block text-sm font-medium text-gray-700">
                Day
              </label>
              <div class="mt-1">
                <.date_input
                  form={f}
                  field={:date}
                  phx_debounce="blur"
                  value={@default_day}
                  required={true}
                />
                <.error form={f} field={:date} />
              </div>
            </div>
            <div class="">
              <label for="end_at" class="block text-sm font-medium text-gray-700">
                Hours
              </label>
              <div class="flex flex-row space-x-2">
                <div class="mt-1">
                  <.select
                    options={time_options()}
                    selected="09:00"
                    form={f}
                    field={:start_at}
                    phx_debounce="blur"
                    required={true}
                  />
                  <.error form={f} field={:start_at} />
                </div>
                <div class="mt-1">
                  <.select
                    options={time_options()}
                    selected="10:00"
                    form={f}
                    field={:end_at}
                    phx_debounce="blur"
                    required={true}
                  />
                  <.error form={f} field={:end_at} />
                </div>
              </div>
            </div>
          </div>
        </.form>
        <:confirm type="submit" form={"#{@id}-form"} phx-disable-with="Saving..." variant={:secondary}>
          Save
        </:confirm>

        <:cancel>Cancel</:cancel>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"booking" => booking_params}, socket) do
    changeset =
      %Booking{}
      |> Schedule.change_booking(booking_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "add_booking",
        %{"booking" => booking_params, "resource_id" => resource_id},
        socket
      ) do
    resource = Resources.get_resource!(resource_id)
    %{"date" => date, "end_at" => end_at, "start_at" => start_at} = booking_params

    start_at = Timex.parse!("#{date} #{start_at}", "{YYYY}-{0M}-{D} {h24}:{m}")
    end_at = Timex.parse!("#{date} #{end_at}", "{YYYY}-{0M}-{D} {h24}:{m}")

    booking_params = %{start_at: start_at, end_at: end_at}

    case Schedule.book_resource(resource, socket.assigns.current_user, booking_params) do
      {:ok, _booking} ->
        hide_modal("#{socket.assigns.id}-modal")

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Booking created successfully."
         )
         |> push_redirect(to: socket.assigns.success_path)}

      {:error, :resource_busy} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "#{resource.name} is unavailable during those hours"
         )
         |> push_redirect(to: socket.assigns.success_path)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp time_options() do
    res =
      for h <- [
            "00",
            "01",
            "02",
            "03",
            "04",
            "05",
            "06",
            "07",
            "08",
            "09",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23"
          ] do
        for m <- ["00", "15", "30", "45"] do
          {"#{h}:#{m}", "#{h}:#{m}"}
        end
      end

    List.flatten(res)
  end
end
