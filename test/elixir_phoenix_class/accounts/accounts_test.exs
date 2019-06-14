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
