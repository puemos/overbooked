defmodule Overbooked.Accounts.RegistrationToken do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Overbooked.Accounts.User

  schema "registration_tokens" do
    field :token, :binary
    field :token_string, :string
    field :scoped_to_email, :string
    belongs_to :used_by_user, User, foreign_key: :used_by_user_id
    belongs_to :generated_by_user, User, foreign_key: :generated_by_user_id

    timestamps()
  end

  @hash_algorithm :sha256
  @rand_size 32
  def build_hashed_token() do
    token_string = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token_string)

    {Base.url_encode64(token_string, padding: false), hashed_token}
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:token, :token_string, :scoped_to_email, :generated_by_user_id])
    |> foreign_key_constraint(:generated_by_user_id)
  end

  @token_validity_in_days 30

  def get_registration_token_query(token) do
    from(rt in __MODULE__,
      where: rt.token == ^token,
      where: rt.inserted_at > ago(@token_validity_in_days, "day"),
      where: is_nil(rt.used_by_user_id)
    )
  end

  def consume_token_changeset(token, user_id) do
    token
    |> cast(%{used_by_user_id: user_id}, [:used_by_user_id])
    |> unique_constraint(:used_by_user_id)
  end
end
