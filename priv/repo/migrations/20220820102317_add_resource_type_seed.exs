defmodule Overbooked.Repo.Migrations.AddResourceTypeSeed do
  use Ecto.Migration
  import Ecto.Query
  alias Overbooked.Repo
  alias Overbooked.Resources.ResourceType

  def up do
    Repo.insert!(%ResourceType{
      name: "room"
    })

    Repo.insert!(%ResourceType{
      name: "desk"
    })
  end

  def down do
    ResourceType
    |> where(name: ["room", "desk"])
    |> Repo.delete_all()
  end
end
