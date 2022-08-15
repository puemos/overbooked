defmodule Overbooked.ResourcesTest do
  use Overbooked.DataCase

  alias Overbooked.Resources

  describe "resources" do
    alias Overbooked.Resources.Resouce

    import Overbooked.ResourcesFixtures

    @invalid_attrs %{name: nil}

    test "list_resources/0 returns all resources" do
      resouce = resouce_fixture()
      assert Resources.list_resources() == [resouce]
    end

    test "get_resouce!/1 returns the resouce with given id" do
      resouce = resouce_fixture()
      assert Resources.get_resouce!(resouce.id) == resouce
    end

    test "create_resouce/1 with valid data creates a resouce" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Resouce{} = resouce} = Resources.create_resouce(valid_attrs)
      assert resouce.name == "some name"
    end

    test "create_resouce/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_resouce(@invalid_attrs)
    end

    test "update_resouce/2 with valid data updates the resouce" do
      resouce = resouce_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Resouce{} = resouce} = Resources.update_resouce(resouce, update_attrs)
      assert resouce.name == "some updated name"
    end

    test "update_resouce/2 with invalid data returns error changeset" do
      resouce = resouce_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_resouce(resouce, @invalid_attrs)
      assert resouce == Resources.get_resouce!(resouce.id)
    end

    test "delete_resouce/1 deletes the resouce" do
      resouce = resouce_fixture()
      assert {:ok, %Resouce{}} = Resources.delete_resouce(resouce)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_resouce!(resouce.id) end
    end

    test "change_resouce/1 returns a resouce changeset" do
      resouce = resouce_fixture()
      assert %Ecto.Changeset{} = Resources.change_resouce(resouce)
    end
  end
end
