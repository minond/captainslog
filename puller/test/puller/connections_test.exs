defmodule Puller.ConnectionsTest do
  use Puller.DataCase

  alias Puller.Connections

  describe "sources" do
    alias Puller.Connections.Source
    alias Puller.Users.User

    @alphabet Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)

    @valid_attrs %{data_source: "some data_source"}
    @update_attrs %{data_source: "some updated data_source"}
    @invalid_attrs %{data_source: nil}

    def user_fixture() do
      header = Enum.take_random(@alphabet, 16)
      email = "#{header}@test.com"

      {:ok, user} =
        %User{email: email}
        |> Repo.insert()

      user
    end

    def source_fixture(user, attrs \\ %{}) do
      {:ok, source} =
        attrs
        |> Enum.into(@valid_attrs)
        |> (&Connections.create_source(user, &1)).()

      source
    end

    test "list_sources/0 returns all sources owned by the user" do
      user1 = user_fixture()
      user2 = user_fixture()
      source1 = source_fixture(user1)
      source2 = source_fixture(user1)
      source3 = source_fixture(user2)
      source4 = source_fixture(user2)
      assert Connections.list_sources(user1) == [source2, source1]
      assert Connections.list_sources(user2) == [source4, source3]
    end

    test "get_source!/1 returns the source with given id" do
      user = user_fixture()
      source = source_fixture(user)
      assert Connections.get_source!(user, source.id) == source
    end

    test "create_source/1 with valid data creates a source" do
      user = user_fixture()
      assert {:ok, %Source{} = source} = Connections.create_source(user, @valid_attrs)
      assert source.data_source == "some data_source"
    end

    test "create_source/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Connections.create_source(user, @invalid_attrs)
    end

    test "update_source/2 with valid data updates the source" do
      user = user_fixture()
      source = source_fixture(user)
      assert {:ok, %Source{} = source} = Connections.update_source(source, @update_attrs)
      assert source.data_source == "some updated data_source"
    end

    test "update_source/2 with invalid data returns error changeset" do
      user = user_fixture()
      source = source_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Connections.update_source(source, @invalid_attrs)
      assert source == Connections.get_source!(user, source.id)
    end

    test "delete_source/1 deletes the source" do
      user = user_fixture()
      source = source_fixture(user)
      assert {:ok, %Source{}} = Connections.delete_source(source)
      assert_raise Ecto.NoResultsError, fn -> Connections.get_source!(user, source.id) end
    end

    test "change_source/1 returns a source changeset" do
      user = user_fixture()
      source = source_fixture(user)
      assert %Ecto.Changeset{} = Connections.change_source(source)
    end
  end
end
