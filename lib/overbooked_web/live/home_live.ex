defmodule OverbookedWeb.HomeLive do
  use OverbookedWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    Home
    """
  end
end
