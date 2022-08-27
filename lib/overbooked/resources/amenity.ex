defmodule Overbooked.Resources.Amenity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "amenities" do
    field :name, :string

    many_to_many :resources, Overbooked.Resources.Resource,
      join_through: Overbooked.Resources.ResourceAmenity,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(amenity, attrs) do
    amenity
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2)
  end
end
