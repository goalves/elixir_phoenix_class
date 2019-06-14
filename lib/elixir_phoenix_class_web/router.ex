defmodule EPClassWeb.Router do
  use EPClassWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EPClassWeb do
    pipe_through :api
  end
end
