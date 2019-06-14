defmodule EPClass.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:email, :nickname]
  @required_fields @fields

  schema "users" do
    field(:email, :string)
    field(:nickname, :string)
  end

  def changeset(user, changes) do
    user
    |> cast(changes, @fields)
    |> validate_required(@required_fields)
  end
end
