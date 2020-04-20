defmodule PullerWeb.SourceController do
  use PullerWeb, :controller

  alias Puller.Connections
  alias Puller.Connections.Source

  def index(conn, _params) do
    user = current_user(conn)
    sources = Connections.list_sources(user)
    render(conn, "index.html", sources: sources)
  end

  def new(conn, _params) do
    changeset = Connections.change_source(%Source{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"source" => source_params}) do
    user = current_user(conn)

    case Connections.create_source(user, source_params) do
      {:ok, source} ->
        conn
        |> put_flash(:info, "Source created successfully.")
        |> redirect(to: Routes.source_path(conn, :show, source))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = current_user(conn)
    source = Connections.get_source!(user, id)
    render(conn, "show.html", source: source)
  end

  def edit(conn, %{"id" => id}) do
    user = current_user(conn)
    source = Connections.get_source!(user, id)
    changeset = Connections.change_source(source)
    render(conn, "edit.html", source: source, changeset: changeset)
  end

  def update(conn, %{"id" => id, "source" => source_params}) do
    user = current_user(conn)
    source = Connections.get_source!(user, id)

    case Connections.update_source(source, source_params) do
      {:ok, source} ->
        conn
        |> put_flash(:info, "Source updated successfully.")
        |> redirect(to: Routes.source_path(conn, :show, source))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", source: source, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = current_user(conn)
    source = Connections.get_source!(user, id)
    {:ok, _source} = Connections.delete_source(source)

    conn
    |> put_flash(:info, "Source deleted successfully.")
    |> redirect(to: Routes.source_path(conn, :index))
  end

  defp current_user(conn) do
    Pow.Plug.current_user(conn)
  end
end
