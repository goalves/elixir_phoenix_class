defmodule EPClassWeb.UserView do
  use EPClassWeb, :view

  def render("index.json", %{users: users}),
    do: render_many(users, __MODULE__, "user.json")

  def render("show.json", %{user: user}),
    do: render_one(user, __MODULE__, "user.json")

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      nickname: user.nickname
    }
  end
end
