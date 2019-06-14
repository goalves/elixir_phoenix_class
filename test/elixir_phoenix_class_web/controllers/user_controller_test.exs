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

      response =
        conn
        |> delete(Routes.user_path(conn, :delete, inexistent_user_id))
        |> json_response(:not_found)

      assert response["errors"]["detail"] == "Not Found"
    end
  end
end
