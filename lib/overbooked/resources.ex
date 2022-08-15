defmodule Overbooked.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false
  alias Overbooked.Repo

  alias Overbooked.Resources.Resouce

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Resouce{}, ...]

  """
  def list_resources do
    Repo.all(Resouce)
  end

  @doc """
  Gets a single resouce.

  Raises `Ecto.NoResultsError` if the Resouce does not exist.

  ## Examples

      iex> get_resouce!(123)
      %Resouce{}

      iex> get_resouce!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resouce!(id), do: Repo.get!(Resouce, id)

  @doc """
  Creates a resouce.

  ## Examples

      iex> create_resouce(%{field: value})
      {:ok, %Resouce{}}

      iex> create_resouce(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resouce(attrs \\ %{}) do
    %Resouce{}
    |> Resouce.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resouce.

  ## Examples

      iex> update_resouce(resouce, %{field: new_value})
      {:ok, %Resouce{}}

      iex> update_resouce(resouce, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resouce(%Resouce{} = resouce, attrs) do
    resouce
    |> Resouce.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a resouce.

  ## Examples

      iex> delete_resouce(resouce)
      {:ok, %Resouce{}}

      iex> delete_resouce(resouce)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resouce(%Resouce{} = resouce) do
    Repo.delete(resouce)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resouce changes.

  ## Examples

      iex> change_resouce(resouce)
      %Ecto.Changeset{data: %Resouce{}}

  """
  def change_resouce(%Resouce{} = resouce, attrs \\ %{}) do
    Resouce.changeset(resouce, attrs)
  end
end
