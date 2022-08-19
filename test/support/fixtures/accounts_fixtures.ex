defmodule Overbooked.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Overbooked.Accounts` context.
  """

  alias Overbooked.Accounts.{User}
  alias Overbooked.Repo

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_name, do: "John Malu"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      name: valid_user_name()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      %User{}
      |> User.registration_changeset(valid_user_attributes(attrs))
      |> Repo.insert()

    user
  end

  def admin_fixture() do
    admin_email =
      Overbooked.config([:admin_emails])
      |> List.first()

    {:ok, user} =
      case Overbooked.Accounts.get_user_by_email(admin_email) do
        %User{} = user ->
          {:ok, user}

        _ ->
          %User{}
          |> User.registration_changeset(%{
            email: admin_email,
            password: "admin"
          })
          |> Repo.insert()
      end

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def registration_token_fixture(email \\ nil) do
    {:ok, token} = Overbooked.Accounts.generate_registration_token(scoped_to_email: email)
    token
  end
end
