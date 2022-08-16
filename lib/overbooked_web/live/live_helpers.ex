defmodule OverbookedWeb.LiveHelpers do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-sidebar-container", transition: "fade-in")
    |> JS.show(
      to: "#mobile-sidebar",
      display: "flex",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full", "translate-x-0"}
    )
    |> JS.hide(to: "#show-mobile-sidebar", transition: "fade-out")
    |> JS.dispatch("js:exec", to: "#hide-mobile-sidebar", detail: %{call: "focus", args: []})
  end

  def hide_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(to: "#mobile-sidebar-container", transition: "fade-out")
    |> JS.hide(
      to: "#mobile-sidebar",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0", "-translate-x-full"}
    )
    |> JS.show(to: "#show-mobile-sidebar", transition: "fade-in")
    |> JS.dispatch("js:exec", to: "#show-mobile-sidebar", detail: %{call: "focus", args: []})
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      display: "inline-block",
      transition:
        {"ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 300,
      transition:
        {"transition ease-in duration-300", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end

  @doc """
  Calls a wired up event listener to call a function with arguments.

      window.addEventListener("js:exec", e => e.target[e.detail.call](...e.detail.args))
  """
  def js_exec(js \\ %JS{}, to, call, args) do
    JS.dispatch(js, "js:exec", to: to, detail: %{call: call, args: args})
  end

  def focus(js \\ %JS{}, parent, to) do
    JS.dispatch(js, "js:focus", to: to, detail: %{parent: parent})
  end

  def focus_closest(js \\ %JS{}, to) do
    js
    |> JS.dispatch("js:focus-closest", to: to)
    |> hide(to)
  end
end
