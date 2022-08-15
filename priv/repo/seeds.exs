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

for email <- Overbooked.config([:admin_emails]) do
  Overbooked.Accounts.register_user(%{
    email: email,
    password: "admin"
  })
end
