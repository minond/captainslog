defmodule Puller.Connections do
  @moduledoc """
  The Connections context.
  """

  import Ecto.Query, warn: false
  alias Puller.Repo

  alias Puller.Connections.Source

  @doc """
  Returns the list of sources.

  ## Examples

      iex> list_sources(user)
      [%Source{}, ...]

  """
  def list_sources(user) do
    Repo.all(from s in Source, where: s.user_id == ^user.id)
  end

  @doc """
  Gets a single source.

  Raises `Ecto.NoResultsError` if the Source does not exist.

  ## Examples

      iex> get_source!(user, 123)
      %Source{}

      iex> get_source!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_source!(user, id) do
    Repo.get_by!(Source, id: id, user_id: user.id)
  end

  @doc """
  Creates a source.

  ## Examples

      iex> create_source(user, %{field: value})
      {:ok, %Source{}}

      iex> create_source(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_source(user, attrs \\ %{}) do
    %Source{user_id: user.id}
    |> Source.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a source.

  ## Examples

      iex> update_source(source, %{field: new_value})
      {:ok, %Source{}}

      iex> update_source(source, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_source(%Source{} = source, attrs) do
    source
    |> Source.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a source.

  ## Examples

      iex> delete_source(source)
      {:ok, %Source{}}

      iex> delete_source(source)
      {:error, %Ecto.Changeset{}}

  """
  def delete_source(%Source{} = source) do
    Repo.delete(source)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking source changes.

  ## Examples

      iex> change_source(source)
      %Ecto.Changeset{source: %Source{}}

  """
  def change_source(%Source{} = source) do
    Source.changeset(source, %{})
  end
end
