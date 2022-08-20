defmodule Overbooked.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field :name, :string
    has_many :bookings, Overbooked.Scheduler.Booking
    belongs_to :resource_type, Overbooked.Resources.ResourceType
    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def put_resource_type(
        %Ecto.Changeset{} = changeset,
        %Overbooked.Resources.ResourceType{} = resource_type
      ) do
    put_assoc(changeset, :resource_type, resource_type)
  end
end
