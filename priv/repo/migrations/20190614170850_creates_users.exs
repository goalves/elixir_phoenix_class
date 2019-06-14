defmodule EPClass.Repo.Migrations.CreatesUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string, null: false)
      add(:nickname, :string, null: false)
    end
  end
end
