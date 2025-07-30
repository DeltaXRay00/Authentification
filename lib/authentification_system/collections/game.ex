defmodule AuthentificationSystem.Collections.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :title, :string
    field :company, :string
    field :released_year, :integer
    field :genre, :string
    field :platform, :string

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:title, :company, :released_year, :genre, :platform])
    |> validate_required([:title, :company, :released_year, :genre, :platform])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:company, min: 1, max: 255)
    |> validate_length(:genre, min: 1, max: 100)
    |> validate_length(:platform, min: 1, max: 255)
    |> validate_number(:released_year, greater_than: 1900, less_than: 2030)
  end
end
