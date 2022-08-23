defmodule Overbooked.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string
    field :color, :string, default: "gray"
    field :booking_count, :integer, virtual: true

    has_many :bookings, Overbooked.Schedule.Booking

    many_to_many :amenities, Overbooked.Resources.Amenity,
      join_through: Overbooked.Resources.ResourceAmenity,
      on_replace: :delete

    belongs_to :resource_type, Overbooked.Resources.ResourceType
    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name, :color])
    |> validate_required([:name, :color])
  end

  def put_resource_type(
        %Ecto.Changeset{} = changeset,
        %Overbooked.Resources.ResourceType{} = resource_type
      ) do
    put_assoc(changeset, :resource_type, resource_type)
  end

  def put_amenities(
        %Ecto.Changeset{} = changeset,
        amenities
      ) do
    put_assoc(changeset, :amenities, amenities)
  end
end
