defmodule Voli.Accounts.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "friendships" do
    field :status, :string

    belongs_to :requester, Voli.Accounts.User, foreign_key: :requester_id
    belongs_to :receiver, Voli.Accounts.User, foreign_key: :receiver_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
