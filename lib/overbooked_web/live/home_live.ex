defmodule OverbookedWeb.HomeLive do
  use OverbookedWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header label="Home" />
    <div class="px-4 py-4 sm:px-6 lg:px-8 max-w-xl">Sweet home</div>
    """
  end
end
