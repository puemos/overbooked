defmodule Overbooked.Repo.Migrations.AddDefaultAdmin do
  use Ecto.Migration

  def change do
    Overbooked.Repo.insert!(%Overbooked.Accounts.User{
      admin: true,
      email: "admin@overbooked.app",
      name: "admin",
      confirmed_at: ~N[2022-08-20 23:00:07],
      hashed_password: Bcrypt.hash_pwd_salt("Aa123123123123!")
    })
  end
end
