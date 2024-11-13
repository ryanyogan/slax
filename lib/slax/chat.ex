defmodule Slax.Chat do
  alias Slax.Chat.Room
  alias Slax.Repo

  import Ecto.Query

  @doc """
  Returns the first room in the database.
  """
  def get_first_room! do
    Repo.one!(from r in Room, limit: 1, order_by: [asc: :name])
  end

  @doc """
  Returns the room with the given `id`.
  """
  def get_room!(id) do
    Repo.get!(Room, id)
  end

  @doc """
  Returns all rooms in the database.
  """
  def list_rooms do
    Repo.all(from r in Room, order_by: [asc: :name])
  end

  @doc """
  Creates a room with the given attributes.
  """
  def create_room(attrs) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates the room with the given `room` struct and attributes.
  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end
end
