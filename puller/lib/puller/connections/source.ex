defmodule Puller.Connections.Source do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sources" do
    field :data_source, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:data_source])
    |> validate_required([:data_source])
  end
end
