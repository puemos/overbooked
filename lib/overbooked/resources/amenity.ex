defmodule Overbooked.Resources.Amenity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "amenities" do
    field :count, :integer
    field :name, :string

    many_to_many :resources, Overbooked.Resources.Resource,
      join_through: Overbooked.Resources.ResourceAmenity,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(amenity, attrs) do
    amenity
    |> cast(attrs, [:name, :count])
    |> validate_required([:name, :count])
  end
end
