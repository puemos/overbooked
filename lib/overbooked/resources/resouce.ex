defmodule Overbooked.Resources.Resouce do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(resouce, attrs) do
    resouce
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
