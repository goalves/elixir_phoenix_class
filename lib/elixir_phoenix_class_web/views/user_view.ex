defmodule EPClassWeb.UserView do
  use EPClassWeb, :view

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      nickname: user.nickname
    }
  end
end
