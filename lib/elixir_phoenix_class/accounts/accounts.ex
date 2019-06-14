defmodule EPClass.Accounts do
  alias EPClass.Repo
  alias EPClass.Accounts.User

  def create_user(changes) do
    %User{}
    |> User.changeset(changes)
    |> Repo.insert()
  end

  def update_user(user, changes) do
    user
    |> User.changeset(changes)
    |> Repo.update()
  end

  def delete_user(user) do
    Repo.delete(user)
  end

  def list_users() do
    Repo.all(User)
  end

  def get_user(id) do
    User
    |> Repo.get(id)
    |> case do
      nil -> {:error, :user_does_not_exist}
      user -> {:ok, user}
    end
  end
end
