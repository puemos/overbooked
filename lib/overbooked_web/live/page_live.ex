defmodule OverbookedWeb.PageLive do
  use OverbookedWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.color_scheme_switch />
    """
  end
end
