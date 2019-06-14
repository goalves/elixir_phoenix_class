defmodule EPClass.Accounts.UserTest do
  use EPClass.DataCase, async: true
  alias EPClass.Accounts.User

  describe "changeset/2" do
    @valid_parameters %{email: "some_email@email.com", nickname: "some nickname"}
    @invalid_parameters %{email: nil, nickname: nil}

    test "should return a valid changeset" do
      assert User.changeset(%User{}, @valid_parameters).valid?
    end

    test "should return an invalid changeset if parameters are missing" do
      refute User.changeset(%User{}, @invalid_parameters).valid?
    end
  end
end
