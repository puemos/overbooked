defmodule Overbooked.ResourcesTest do
  use Overbooked.DataCase

  import Overbooked.ResourcesFixtures

  alias Overbooked.Resources
  alias Overbooked.Resources.{Amenity, Resource}

  describe "resources" do
    @invalid_attrs %{name: nil}

    test "list_resources/0 returns all resources" do
      resource = resource_fixture()
      resource_id = resource.id
      assert [%Resource{id: ^resource_id}] = Resources.list_resources()
    end

    test "get_resource!/1 returns the resource with given id" do
      resource = resource_fixture()
      resource_id = resource.id
      assert %Resource{id: ^resource_id} = Resources.get_resource!(resource.id)
    end

    test "create_resource/1 with valid data creates a resource" do
      valid_attrs = %{name: "some name"}
      resource_type = resource_type_fixture()

      assert {:ok, %Resource{} = resource} = Resources.create_resource(resource_type, valid_attrs)
      assert resource.name == "some name"
    end

    test "create_resource/1 with invalid data returns error changeset" do
      resource_type = resource_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Resources.create_resource(resource_type, @invalid_attrs)
    end

    test "update_resource/2 with valid data updates the resource" do
      resource = resource_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Resource{} = resource} = Resources.update_resource(resource, update_attrs)
      assert resource.name == "some updated name"
    end

    test "update_resource/2 with invalid data returns error changeset" do
      resource = resource_fixture()
      resource_name = resource.name
      assert {:error, %Ecto.Changeset{}} = Resources.update_resource(resource, @invalid_attrs)
      assert %Resource{name: ^resource_name} = Resources.get_resource!(resource.id)
    end

    test "delete_resource/1 deletes the resource" do
      resource = resource_fixture()
      assert {:ok, %Resource{}} = Resources.delete_resource(resource)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_resource!(resource.id) end
    end

    test "change_resource/1 returns a resource changeset" do
      resource = resource_fixture()
      assert %Ecto.Changeset{} = Resources.change_resource(resource)
    end

    test "update_resource_amenities/2 with valid data updates the resource" do
      resource = resource_fixture()

      {:ok, %Amenity{} = coffee_amenity} = Resources.create_amenity(%{count: 2, name: "coffee"})
      {:ok, %Amenity{} = screen_amenity} = Resources.create_amenity(%{count: 1, name: "screen"})

      assert {:ok, %Resource{} = resource} =
               Resources.update_resource_amenities(resource, [coffee_amenity, screen_amenity])

      resource = Overbooked.Repo.preload(resource, :amenities)

      assert [coffee_amenity, screen_amenity] == resource.amenities
    end
  end

  describe "amenities" do
    @invalid_attrs %{count: nil, name: nil}

    test "list_amenities/0 returns all amenities" do
      amenity = amenity_fixture()
      assert Resources.list_amenities() == [amenity]
    end

    test "get_amenity!/1 returns the amenity with given id" do
      amenity = amenity_fixture()
      assert Resources.get_amenity!(amenity.id) == amenity
    end

    test "create_amenity/1 with valid data creates a amenity" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Amenity{} = amenity} = Resources.create_amenity(valid_attrs)
      assert amenity.name == "some name"
    end

    test "create_amenity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_amenity(@invalid_attrs)
    end

    test "update_amenity/2 with valid data updates the amenity" do
      amenity = amenity_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Amenity{} = amenity} = Resources.update_amenity(amenity, update_attrs)
      assert amenity.name == "some updated name"
    end

    test "update_amenity/2 with invalid data returns error changeset" do
      amenity = amenity_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_amenity(amenity, @invalid_attrs)
      assert amenity == Resources.get_amenity!(amenity.id)
    end

    test "delete_amenity/1 deletes the amenity" do
      amenity = amenity_fixture()
      assert {:ok, %Amenity{}} = Resources.delete_amenity(amenity)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_amenity!(amenity.id) end
    end

    test "change_amenity/1 returns a amenity changeset" do
      amenity = amenity_fixture()
      assert %Ecto.Changeset{} = Resources.change_amenity(amenity)
    end
  end
end
