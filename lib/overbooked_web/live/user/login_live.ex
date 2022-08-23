defmodule OverbookedWeb.LoginLive do
  use OverbookedWeb, :live_view

  alias OverbookedWeb.Router.Helpers, as: Routes
  import Phoenix.HTML.Form

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header label="Log in"></.header>
    <.page>
      <div class="max-w-md mx-auto mt-6">
        <.form
          :let={f}
          action={Routes.user_session_path(@socket, :create)}
          for={:user}
          id="login-form"
          class="flex flex-col space-y-4"
        >
          <div class="">
            <label for="email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <div class="mt-1">
              <.text_input form={f} field={:email} required={true} />
              <.error form={f} field={:email} />
            </div>
          </div>
          <div class="">
            <label for="password" class="block text-sm font-medium text-gray-700">
              Password
            </label>
            <div class="mt-1">
              <.password_input
                form={f}
                field={:password}
                value={input_value(f, :password)}
                required={true}
              />
              <.error form={f} field={:password} />
            </div>
          </div>
          <div class="">
            <div class="flex flex-row items-baseline space-x-2">
              <div class="mt-1">
                <.checkbox form={f} field={:remember_me} value={input_value(f, :password)} />
              </div>
              <label for="remember_me" class="block text-sm font-medium text-gray-700">
                Keep me logged in for 60 days
              </label>
            </div>
          </div>

          <div class="py-2">
            <.button type="submit" phx-disable-with="Logging...">Login</.button>
          </div>
        </.form>

        <p class="mt-6">
          <.link class="text-sm" navigate={Routes.user_forgot_password_path(@socket, :index)}>
            Forgot your password?
          </.link>
        </p>
      </div>
    </.page>
    """
  end
end
