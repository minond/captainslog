defmodule Puller.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :data_source, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:sources, [:user_id])
  end
end
