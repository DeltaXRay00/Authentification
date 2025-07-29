defmodule AuthentificationSystem.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :title, :string, null: false
      add :company, :string, null: false
      add :release_date, :date, null: false
      add :genre, :string, null: false
      add :platform, :string, null: false

      timestamps()
    end

    create index(:games, [:title])
    create index(:games, [:company])
    create index(:games, [:genre])
  end
end
