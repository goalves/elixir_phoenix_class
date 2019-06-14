defmodule EPClass.Accounts do
  alias EPClass.Repo
  alias EPClass.Accounts.User

  def create_user(changes) do
    %User{}
    |> User.changeset(changes)
    |> Repo.insert()
  end
end
