defmodule Overbooked.ResourcesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Overbooked.Resources` context.
  """

  @doc """
  Generate a resouce.
  """
  def resouce_fixture(attrs \\ %{}) do
    {:ok, resouce} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Overbooked.Resources.create_resouce()

    resouce
  end
end
