defmodule Overbooked.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Overbooked.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Overbooked.Accounts.register_user()

    user
  end

  def admin_fixture() do
    admin_email =
      Overbooked.config([:admin_emails])
      |> List.first()

    {:ok, user} =
      case Overbooked.Accounts.get_user_by_email(admin_email) do
        %Overbooked.Accounts.User{} = user ->
          {:ok, user}

        _ ->
          Overbooked.Accounts.register_user(%{
            email: admin_email,
            password: "admin"
          })
      end

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
