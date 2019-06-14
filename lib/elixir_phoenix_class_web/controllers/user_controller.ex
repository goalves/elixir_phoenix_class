defmodule EPClassWeb.UserController do
  use EPClassWeb, :controller
  alias EPClass.Accounts

  def create(conn, params) do
    {:ok, user} = Accounts.create_user(params) |> IO.inspect()
    send_resp(conn, :ok, "created the user")
  end
end
