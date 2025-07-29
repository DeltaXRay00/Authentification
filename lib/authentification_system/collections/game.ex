defmodule AuthentificationSystem.Collections.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :title, :string
    field :company, :string
    field :release_date, :date
    field :genre, :string
    field :platform, :string

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:title, :company, :release_date, :genre, :platform])
    |> validate_required([:title, :company, :release_date, :genre, :platform])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:company, min: 1, max: 255)
    |> validate_length(:genre, min: 1, max: 100)
    |> validate_length(:platform, min: 1, max: 255)
  end
end
