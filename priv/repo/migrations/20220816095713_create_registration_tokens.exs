defmodule Overbooked.Repo.Migrations.CreateRegistrationTokens do
  use Ecto.Migration

  def change do
    create table(:registration_tokens) do
      add :token, :binary, null: false
      add :token_string, :string, null: false
      add :used_by_user_id, references(:users, on_delete: :delete_all)
      add :scoped_to_email, :string
      add :generated_by_user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:registration_tokens, [:used_by_user_id])
  end
end
