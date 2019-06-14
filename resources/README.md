# Little tutorial about this Project

The intent of this project is to teach some stuff about elixir/phoenix with a few good practices.
We are going to be demoing lots of stuff and in the end, we are going to do something not planned :).

## Overview of generated project files/folders

The system is divided in some basic folders:

```sh
➜ tree -L 1 -d
.
├── _build
├── config
├── deps
├── lib
├── priv
├── resources
└── test

7 directories
```

The main files for our application are:

```sh
➜ tree -L 3
.
├── README.md
├── config
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   ├── prod.secret.exs
│   └── test.exs
├── docker-compose.yaml
├── lib
│   ├── elixir_phoenix_class
│   │   ├── application.ex
│   │   └── repo.ex
│   ├── elixir_phoenix_class_web
│   │   ├── router.ex
├── mix.exs
├── mix.lock
└── priv
    └── repo
        ├── migrations
        └── seeds.exs
```

## Storage

Since it is not common to keep state in an Elixir application, we are going to use a PostgresSQL to store data.

### Setting up a Database and connecting to it

Using docker, we are going to start an instance of a postgres database and update the configuration files to work with it.

```docker-compose up -d```

We need to update the `dev.exs` configuration file to properly conect to database and then run the following command to actually create the database:

```mix ecto.create```

### Running database migrations

Migrations are run using `mix ecto.migrate`, we can revert them using `mix ecto.rollback`.

## System Architecture

Since backend development handles directly with data and consistency, it is common to write tests and to organize the codebase in a reliable and maintainable format.

We are going to develop a Backend application that only serves few routes using JSON over HTTP protocol.

The system we are going to build is a simple forum API with users, posts and comments. :)

### General Organization

Generally we use different layers to handle data in backend:

- Controllers;
- Contexts;
- Schemas;
- Views.

### Tests

Tests are always good and they are the base foundation that we rely uppon when we are adding features or updating previous ones.

We are going to do TDD (or try to) here! :)

## Hands on: Creating a Migration

We want to create a new table in the database and add some fields to it, to do so we will run:

```mix ecto.gen.migration create_users```

And then change the content of the created migration to:

```elixir
defmodule EPClass.Repo.Migrations.CreatesUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string, null: false)
      add(:nickname, :string, null: false)
    end
  end
end
```

## Hands on: Creating a Context/Schema

Since our application is divided in contexts/schemas, we want to create a new context and a schema for users.
The context will be called `accounts`, the schema will be called `user`.

Inside the `elixir_phoenix_class` folder, we will create a new folder with two files as follows:

```sh
➜ tree
.
└── elixir_phoenix_class
    ├── accounts
    │   ├── accounts.ex
    │   └── user.ex
    ├── application.ex
    └── repo.ex

```

We will then create a test for the `User` schema and `Accounts` context as follows:

```
test
└── elixir_phoenix_class
    └── accounts
        └── user_test.exs
        └── accounts_test.exs
```

Users file:
```
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
```

Users test file:

```
defmodule EPClass.Accounts.UserTest do
  use EPClass.DataCase, async: true
  alias EPClass.Accounts.User

  describe "changeset/2" do
    @valid_parameters %{email: "some_email@email.com", nickname: "some nickname"}
    @invalid_parameters %{}

    test "should return a valid changeset" do
      assert User.changeset(%User{}, @valid_parameters).valid?
    end

    test "should return an invalid changeset if parameters are missing" do
      refute User.changeset(%User{}, @invalid_parameters).valid?
    end
  end
end
```

Now lets create some functions and tests that will handle manipulation of data in the accounts context.

accounts_test.exs
```elixir
defmodule EPClass.AccountsTest do
  use EPClass.DataCase, async: true
  alias EPClass.Accounts
  alias Ecto.Changeset

  @valid_parameters %{email: "some_email@email.com", nickname: "some nickname"}
  @valid_update_parameters %{email: "some_updated_email@email.com"}
  @invalid_parameters %{email: nil, nickname: nil}

  describe "create_user/1" do
    test "should create a user" do
      assert {:ok, created_user} = Accounts.create_user(@valid_parameters)
      assert created_user.email == @valid_parameters.email
      assert created_user.nickname == @valid_parameters.nickname
    end

    test "should return an error and a changeset if parameters are invalid" do
      assert {:error, changeset = %Changeset{}} = Accounts.create_user(@invalid_parameters)
      assert errors_on(changeset).email == ["can't be blank"]
      assert errors_on(changeset).nickname == ["can't be blank"]
    end
  end

  describe "update_user/2" do
    test "should update an user" do
      {:ok, user} = Accounts.create_user(@valid_parameters)
      assert {:ok, updated_user} = Accounts.update_user(user, @valid_update_parameters)
      assert updated_user.email != user.email
      assert updated_user.email == @valid_update_parameters.email
    end

    test "should return an error and a changeset if paramters are invalid" do
      {:ok, user} = Accounts.create_user(@valid_parameters)

      assert {:error, changeset = %Changeset{}} = Accounts.update_user(user, @invalid_parameters)
    end
  end

  describe "list_users/0" do
    test "should list all users" do
      {:ok, user} = Accounts.create_user(@valid_parameters)
      assert [fetch_user] = Accounts.list_users()
      assert fetch_user.id == user.id
    end
  end

  describe "get_user/1" do
    test "should return an user" do
      {:ok, user} = Accounts.create_user(@valid_parameters)
      assert {:ok, fetch_user} = Accounts.get_user(user.id)
      assert fetch_user.id == user.id
    end

    test "should return an error if the user does not exist" do
      assert {:error, :user_does_not_exist} = Accounts.get_user(0)
    end
  end
end
```

accounts.ex
```
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
```

## Hands on: Creating Controllers/Views

Now that we have some way to let our application store data, we need to create a way for someone outside the application to use it.
We will create a controller that allows us to edit/create/update/delete users.

First we need to change the router file to actually point to a proper controller:

router.ex
```
defmodule EPClassWeb.Router do
  use EPClassWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EPClassWeb do
    pipe_through :api

    resources("/users", UserController, except: [:edit, :new])
  end
end
```

And it will complain that UserController does not exist, lets fix that!

Create a file under lib/elixir_phoenix_class_web/controllers called `user_controller.ex`, as follows:

```sh
➜ tree
.
└── elixir_phoenix_class_web
    └── controllers
        └── user_controller.ex
```

Now it does not complain on `mix phx.routes` anymore, but how are we going to actually show the data?
Lets understand the previous command and create a route that accept those parameters.

user_controller.ex
```
defmodule EPClassWeb.UserController do
  use EPClassWeb, :controller
  alias EPClass.Accounts

  def create(conn, params) do
    {:ok, user} = Accounts.create_user(params) |> IO.inspect()
    send_resp(conn, :ok, "created the user")
  end
end
```

Noticed that I added a `IO.inspect()` piped after the `Accounts.create_user(params)` to see what is happening in there.
How can I actually show part of that data to who is using our API?
Lets write some code that transforms that into a serializable structure (in other words, a view)!

Create a file in the views folder, called `user_view.ex`, as follows:

```sh
➜ tree
.
└── elixir_phoenix_class_web
    └── views
        └── user_view.ex
```

And write something that returns a map from it:

user_view.ex
```elixir
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
```

Now we can try again and it will actually show user information!
Lets finish the other resource actions (get, list, update, delete) with some tests and lets tidy up the code a bit.

user_controller.ex
```
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
```

user_view.ex
```
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
```

We are also going to create a file to handle the default actions when something fails in the controller folder:

default_fallback_controller.ex
```
defmodule EPClassWeb.DefaultFallbackController do
  use EPClassWeb, :controller
  alias EPClassWeb.{ChangesetView, ErrorView}
  require Logger

  def call(conn, {:error, changeset = %Ecto.Changeset{}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ChangesetView)
    |> render("error.json", changeset)
  end

  def call(conn, {:error, :user_does_not_exist}), do: call_not_found_error_view(conn)

  def call(conn, params) do
    Logger.error(
      "Route was called and did not match anything in controller or fallback. Controller:#{
        inspect(conn.private.phoenix_controller)
      }. Method: #{inspect(conn.private.phoenix_action)}. Parameters: #{inspect(conn.body_params)} The error catch was: #{
        inspect(params)
      }."
    )

    conn
    |> put_status(:internal_server_error)
    |> put_view(ErrorView)
    |> render("500.json")
  end

  defp call_not_found_error_view(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.json")
  end
end
```

And then tests:

user_controller_tests.exs
```
defmodule EPClassWeb.UserControllerTest do
  use EPClassWeb.ConnCase, async: true
  alias EPClass.Accounts

  @valid_parameters %{email: "some_email@email.com", nickname: "some_nickname"}

  setup %{conn: conn} do
    {:ok, user} = Accounts.create_user(@valid_parameters)

    %{conn: conn, user: user}
  end

  describe "CREATE /users" do
    test "should create an user", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :create), @valid_parameters)
        |> json_response(:created)

      assert fetched_user = response
      assert {:ok, user} = Accounts.get_user(fetched_user["id"])
      assert user.email == @valid_parameters.email
      assert user.nickname == @valid_parameters.nickname
    end

    test "should return errors if parameters are invalid", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :create), %{})
        |> json_response(:unprocessable_entity)

      assert response["errors"] == [
               %{"email" => ["can't be blank"]},
               %{"nickname" => ["can't be blank"]}
             ]
    end
  end

  describe "UPDATE /users" do
    test "should update an user", %{conn: conn, user: user} do
      response =
        conn
        |> patch(Routes.user_path(conn, :update, user.id), %{"email" => "my_new_email@email.com"})
        |> json_response(:ok)

      assert fetched_user = response
      assert fetched_user["email"] == "my_new_email@email.com"
    end

    test "should return errors if parameters are invalid", %{conn: conn} do
      response =
        conn
        |> post(Routes.user_path(conn, :create), %{})
        |> json_response(:unprocessable_entity)

      assert response["errors"] == [
               %{"email" => ["can't be blank"]},
               %{"nickname" => ["can't be blank"]}
             ]
    end
  end

  describe "GET /users" do
    test "should list all users", %{conn: conn, user: user} do
      response =
        conn
        |> get(Routes.user_path(conn, :index))
        |> json_response(:ok)

      assert [fetched_user] = response
      assert fetched_user["id"] == user.id
    end
  end

  describe "SHOW /users/{:id}" do
    test "should list the specific user", %{conn: conn, user: user} do
      response =
        conn
        |> get(Routes.user_path(conn, :show, user.id))
        |> json_response(:ok)

      assert fetched_user = response
      assert fetched_user["id"] == user.id
    end

    test "should return an error if the user does not exist", %{conn: conn, user: user} do
      inexistent_user_id = user.id + 1

      response =
        conn
        |> get(Routes.user_path(conn, :show, inexistent_user_id))
        |> json_response(:not_found)

      assert response["errors"]["detail"] == "Not Found"
    end
  end

  describe "DELETE /users/{:id}" do
    test "should delete an user", %{conn: conn, user: user} do
      assert conn
             |> delete(Routes.user_path(conn, :delete, user.id))
             |> json_response(:no_content) == ""

      assert {:error, :user_does_not_exist} = Accounts.get_user(user.id)
    end

    test "should return an error if the user does not exist", %{conn: conn, user: user} do
      inexistent_user_id = user.id + 1
        conn

      response =
        |> delete(Routes.user_path(conn, :delete, inexistent_user_id))
        |> json_response(:not_found)

      assert response["errors"]["detail"] == "Not Found"
    end
  end
end
```

Now lets do something different :)