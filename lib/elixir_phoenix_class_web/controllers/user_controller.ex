defmodule EPClassWeb.UserController do
  use EPClassWeb, :controller
  alias EPClass.Accounts

  action_fallback(EPClassWeb.DefaultFallbackController)

  def create(conn, params) do
    {:ok, user} = Accounts.create_user(params)

    conn
    |> put_status(:ok)
    |> render("user.json", %{user: user})
  end
end
