defmodule EPClassWeb.UserController do
  use EPClassWeb, :controller
  alias EPClass.Accounts

  action_fallback(EPClassWeb.DefaultFallbackController)

  def create(conn, params) do
    with {:ok, user} <- Accounts.create_user(params) do
      conn
      |> put_status(:created)
      |> render("show.json", %{user: user})
    end
  end

  def update(conn, params = %{"id" => id}) do
    with {:ok, user} <- Accounts.get_user(id),
         {:ok, updated_user} <- Accounts.update_user(user, params) do
      conn
      |> put_status(:ok)
      |> render("show.json", %{user: updated_user})
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get_user(id),
         {:ok, _} <- Accounts.delete_user(user) do
      conn
      |> put_status(:no_content)
      |> json("")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Accounts.get_user(id) do
      conn
      |> put_status(:ok)
      |> render("show.json", %{user: user})
    end
  end

  def index(conn, _) do
    users = Accounts.list_users()

    conn
    |> put_status(:ok)
    |> render("index.json", %{users: users})
  end
end
