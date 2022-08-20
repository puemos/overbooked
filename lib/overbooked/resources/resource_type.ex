defmodule Overbooked.Resources.ResourceType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resource_types" do
    field :name, :string
    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
