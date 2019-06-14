defmodule EPClass.AccountsTest do
  use EPClass.DataCase, async: true
  alias EPClass.Accounts
  alias Ecto.Changeset

  describe "create_user/1" do
    @valid_parameters %{email: "some_email@email.com", nickname: "some nickname"}
    @invalid_parameters %{email: nil, nickname: nil}

    test "should create a user" do
      assert {:ok, created_user} = Accounts.create_user(@valid_parameters)
      assert created_user.email == "some_email@email.com"
    end

    test "should return an error and a changeset if parameters are invalid" do
      assert {:error, changeset = %Changeset{}} = Accounts.create_user(@invalid_parameters)
      assert errors_on(changeset).email == ["can't be blank"]
      assert errors_on(changeset).nickname == ["can't be blank"]
    end
  end

  describe "update_user/2" do
    test "should update an user" do
    end

    test "should return an error and a changeset if paramters are invalid" do
    end
  end

  describe "list_users/0" do
    test "should list all users" do
    end
  end

  describe "get_user/1" do
    test "should return an user" do
    end

    test "should return an error if the user does not exist" do
    end
  end
end
