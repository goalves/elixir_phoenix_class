defmodule EPClassWeb.UserController do
  use EPClassWeb, :controller
  alias EPClass.Accounts

  def create(conn, params) do
    {:ok, user} = Accounts.create_user(params)

    conn
    |> put_status(:ok)
    |> render("user.json", %{user: user})
  end
end
