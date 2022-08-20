# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Overbooked.Repo.insert!(%Overbooked.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Overbooked.Accounts.{User}
alias Overbooked.Repo

for email <- Overbooked.config([:admin_emails]) do
  %User{}
  |> User.registration_changeset(%{
    email: email,
    password: "Aa123123123123!",
    name: "Admin"
  })
  |> Repo.insert!()
end
