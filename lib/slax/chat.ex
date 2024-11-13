defmodule Slax.Chat do
  alias Slax.Chat.Room
  alias Slax.Repo

  @doc """
  Returns the first room in the database.
  """
  def get_first_room! do
    [room | _] = list_rooms()
    room
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
    Room |> Repo.all()
  end
end
