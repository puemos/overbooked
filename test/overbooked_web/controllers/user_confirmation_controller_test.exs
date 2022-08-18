defmodule OverbookedWeb.UserConfirmationControllerTest do
  use OverbookedWeb.ConnCase

  alias Overbooked.Accounts
  alias Overbooked.Repo
  import Overbooked.AccountsFixtures
  import Phoenix.LiveViewTest

  setup do
    %{user: user_fixture()}
  end
end
