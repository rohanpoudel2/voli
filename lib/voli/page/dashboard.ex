defmodule Voli.Page.Dashboard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "index" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dashboard, attrs) do
    dashboard
    |> cast(attrs, [])
    |> validate_required([])
  end
end
