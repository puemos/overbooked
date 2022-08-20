defmodule Overbooked.ResourcesTest do
  use Overbooked.DataCase

  alias Overbooked.Resources

  describe "resources" do
    alias Overbooked.Resources.Resource

    import Overbooked.ResourcesFixtures

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
  end
end
