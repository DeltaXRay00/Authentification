defmodule AuthentificationSystem.Collections.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :author, :string
    field :published_year, :integer
    field :genre, :string

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :author, :published_year, :genre])
    |> validate_required([:title, :author, :published_year, :genre])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:author, min: 1, max: 255)
    |> validate_length(:genre, min: 1, max: 100)
    |> validate_number(:published_year, greater_than: 1000, less_than: 2100)
  end
end
