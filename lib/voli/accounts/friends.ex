defmodule Voli.Accounts.Friends do
  use Ecto.Schema
  import Ecto.Changeset

  schema "index" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friends, attrs) do
    friends
    |> cast(attrs, [])
    |> validate_required([])
  end
end
