defmodule Overbooked.ResourcesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Overbooked.Resources` context.
  """

  alias Overbooked.Resources
  alias Overbooked.Resources.{ResourceType}

  def valid_resource_name, do: "Resource"

  def valid_resource_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: valid_resource_name()
    })
  end

  def resource_type_fixture() do
    Resources.get_resource_type_by_name!("room")
  end

  @doc """
  Generate a resource.
  """
  def resource_fixture() do
    Resources.get_resource_type_by_name!("room")
    |> resource_fixture(valid_resource_attributes(%{}))
  end

  def resource_fixture(attrs) do
    Resources.get_resource_type_by_name!("room")
    |> resource_fixture(valid_resource_attributes(attrs))
  end

  def resource_fixture(:room, attrs) do
    Resources.get_resource_type_by_name!("room")
    |> resource_fixture(valid_resource_attributes(attrs))
  end

  def resource_fixture(:desk, attrs) do
    Resources.get_resource_type_by_name!("desk")
    |> resource_fixture(valid_resource_attributes(attrs))
  end

  def resource_fixture(%ResourceType{} = resource_type, attrs) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "some name"
      })

    {:ok, resource} = Resources.create_resource(resource_type, attrs)

    resource
  end

  @doc """
  Generate a amenity.
  """
  def amenity_fixture(attrs \\ %{}) do
    {:ok, amenity} =
      attrs
      |> Enum.into(%{
        count: 42,
        name: "some name"
      })
      |> Overbooked.Resources.create_amenity()

    amenity
  end
end
