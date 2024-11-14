defmodule Slax.Chat do
  alias Slax.Chat.{Room, Message}
  alias Slax.Repo
  alias Slax.Accounts.User

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

  @doc """
  Changes the room with the given `room` struct and attributes.
  """
  def change_room(room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  @doc """
  Lists all messages in the room with the given `room_id`.
  """
  def list_messages_in_room(%Room{id: room_id}) do
    Message
    |> where([m], m.room_id == ^room_id)
    |> order_by([m], asc: :inserted_at, asc: :id)
    |> preload(:user)
    |> Repo.all()
  end

  def change_message(message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def create_message(room, attrs, user) do
    %Message{room: room, user: user}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def delete_message_by_id(id, %User{id: user_id}) do
    message = %Message{user_id: ^user_id} = Repo.get(Message, id)
    Repo.delete(message)
  end
end
