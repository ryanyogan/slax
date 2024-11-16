defmodule SlaxWeb.ChatComponents do
  use SlaxWeb, :live_component

  import SlaxWeb.CoreComponents

  alias Slax.Chat.{Message, Room}
  alias Slax.Accounts.User

  attr :form, Phoenix.HTML.Form, required: true

  def room_form(assigns) do
    ~H"""
    <.simple_form for={@form} id="room-form" phx-change="validate-room" phx-submit="save-room">
      <.input field={@form[:name]} type="text" label="Name" />
      <.input field={@form[:topic]} type="text" label="Topic" />
      <:actions>
        <.button phx-disable-with="Saving..." class="w-full">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  attr :message, Message, required: true
  attr :dom_id, :string, required: true
  attr :timezone, :string, required: true
  attr :current_user, User, required: true

  def message(assigns) do
    ~H"""
    <div class="group relative flex px-4 py-3" id={@dom_id}>
      <button
        :if={@current_user.id == @message.user_id}
        data-confirm="Are you sure?"
        phx-click="delete-message"
        phx-value-id={@message.id}
        class="absolute top-4 right-4 text-red-500 hover:text-red-800 cursor-pointer hidden group-hover:block"
      >
        <.icon name="hero-trash" class="size-4" />
      </button>

      <img class="size-10 rounded flex-shrink-0" src={~p"/images/one_ring.jpg"} />

      <div class="ml-2">
        <div class="-mt-1">
          <.link class="text-sm font-semibold hover:underline">
            <span><%= @message.user.username %></span>
          </.link>
          <span :if={@timezone} class="ml-1 text-xs text-gray-500">
            <%= message_timestmp(@message, @timezone) %>
          </span>
          <p class="text-sm"><%= @message.body %></p>
        </div>
      </div>
    </div>
    """
  end

  attr :count, :integer, required: true

  def unread_message_counter(assigns) do
    ~H"""
    <span
      :if={@count > 0}
      class="flex items-center justify-center bg-blue-500 rounded-full font-medium h-5 px-2 ml-auto text-xs text-white"
    >
      <%= @count %>
    </span>
    """
  end

  attr :active, :boolean, required: true
  attr :room, Room, required: true
  attr :unread_count, :integer, required: true

  def room_link(assigns) do
    ~H"""
    <.link
      class={[
        "flex items-center h-8 text-sm pl-8 pr-3",
        (@active && "bg-slate-300") || "hover:bg-slate-300"
      ]}
      patch={~p"/rooms/#{@room}"}
    >
      <.icon name="hero-hashtag" class="size-4" />
      <span class={["ml-2 leading-none", @active && "font-bold"]}>
        <%= @room.name %>
      </span>
      <.unread_message_counter count={@unread_count} />
    </.link>
    """
  end

  attr :user, User, required: true
  attr :online, :boolean, default: false

  def user(assigns) do
    ~H"""
    <.link class="flex items-center h-8 hover:bg-gray-300 text-sm pl-8 pr-3" href="#">
      <div class="flex justify-center w-4">
        <%= if @online do %>
          <span class="size-2 rounded-full bg-blue-500"></span>
        <% else %>
          <span class="size-2 rounded-full border-2 border-gray-500"></span>
        <% end %>
      </div>
      <span class="ml-2 leading-none"><%= @user.username %></span>
    </.link>
    """
  end

  attr :dom_id, :string, required: true
  attr :text, :string, required: true
  attr :on_click, JS, required: true

  def toggler(assigns) do
    ~H"""
    <button id={@dom_id} phx-click={@on_click} class="flex items-center flex-grow focus:outline-none">
      <.icon id={@dom_id <> "-chevron-down"} name="hero-chevron-down" class="h-4 w-4" />
      <.icon
        id={@dom_id <> "-chevron-right"}
        name="hero-chevron-right"
        class="h-4 w-4"
        style="display:none;"
      />
      <span class="ml-2 leading-none font-medium text-sm">
        <%= @text %>
      </span>
    </button>
    """
  end

  defp message_timestmp(message, timezone) do
    message.inserted_at
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%-l:%M %p", :strftime)
  end
end
