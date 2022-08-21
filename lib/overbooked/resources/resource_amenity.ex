defmodule Overbooked.Resources.ResourceAmenity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resuorce_amenities" do

    field :resource_id, :id
    field :amenity_id, :id

    timestamps()
  end

  @doc false
  def changeset(resource_amenity, attrs) do
    resource_amenity
    |> cast(attrs, [])
    |> validate_required([])
  end
end
