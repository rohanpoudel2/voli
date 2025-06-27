defmodule Voli.Accounts.Friends do
  use Ecto.Schema
  import Ecto.Changeset

  schema "index" do


    timestamps(type: :utc_datetime)
  end

  def change_friend_search(attrs \\ %{}) do
    {%{}, %{email: :string}}
    |> Ecto.Changeset.cast(attrs, [:email])
    |> Ecto.Changeset.validate_required([:email])
    |> Ecto.Changeset.validate_format(:email, ~r/@/, message: "must have the @ sign and no spaces")
  end

  @doc false
  def changeset(friends, attrs) do
    friends
    |> cast(attrs, [])
    |> validate_required([])
  end
end
