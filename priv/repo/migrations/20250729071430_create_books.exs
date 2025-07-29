defmodule AuthentificationSystem.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string, null: false
      add :author, :string, null: false
      add :published_year, :integer, null: false
      add :genre, :string, null: false

      timestamps()
    end

    create index(:books, [:title])
    create index(:books, [:author])
    create index(:books, [:genre])
  end
end
