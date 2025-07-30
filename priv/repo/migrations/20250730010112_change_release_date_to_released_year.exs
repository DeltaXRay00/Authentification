defmodule AuthentificationSystem.Repo.Migrations.ChangeReleaseDateToReleasedYear do
  use Ecto.Migration

  def change do
    # Add the new released_year column
    alter table(:games) do
      add :released_year, :integer
    end

    # Update existing data to extract year from release_date
    execute """
    UPDATE games
    SET released_year = EXTRACT(YEAR FROM release_date)
    WHERE release_date IS NOT NULL
    """, ""

    # Remove the old release_date column
    alter table(:games) do
      remove :release_date
    end
  end
end
