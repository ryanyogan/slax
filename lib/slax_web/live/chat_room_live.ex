defmodule SlaxWeb.ChatRoomLive do
  use SlaxWeb, :live_view

  import SlaxWeb.ChatComponents

  alias SlaxWeb.ChatRoomEventHandlers
  alias SlaxWeb.OnlineUsers

  @impl true

  def render(assigns) do
    ~H"""
    <div class="h-screen flex overflow-hidden bg-white w-full">
      <%!-- Overlay for mobile sidebar --%>
      <div
        :if={@show_mobile_sidebar?}
        class="fixed inset-0 bg-gray-600 z-10 bg-opacity-75 transition-opacity lg:hidden"
        phx-click="toggle-mobile-sidebar"
      />

      <%!-- Mobile sidebar --%>
      <div class={[
        "fixed inset-y-0 left-0 flex w-64 transition z-10 duration-300 transform lg:translate-x-0 lg:static lg:inset-auto",
        @show_mobile_sidebar? && "translate-x-0",
        !@show_mobile_sidebar? && "-translate-x-full"
      ]}>
        <div id="sidebar" class="flex flex-col flex-shrink-0 w-64 bg-slate-100">
          <div class="flex justify-between items-center flex-shrink-0 h-16 border-b border-slate-300 px-4">
            <div class="flex flex-col gap-1.5">
              <h1 class="text-lg font-bold text-gray-800">Slax</h1>
            </div>
            <%!-- Close button for mobile --%>
            <button
              class="lg:hidden rounded-md text-gray-600 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-slate-500"
              phx-click="toggle-mobile-sidebar"
            >
              <span class="sr-only">Close sidebar</span>
              <.icon name="hero-x-mark" class="h-6 w-6" />
            </button>
          </div>

          <div class="mt-4 overflow-auto">
            <div class="flex items-center h-8 px-3 group">
              <.toggler dom_id="rooms-toggler" on_click={toggle_rooms()} text="Rooms" />
            </div>

            <div id="rooms-list">
              <.room_link
                :for={{room, unread_count} <- @rooms}
                room={room}
                active={room.id == @room.id}
                unread_count={unread_count}
              />
              <button class="group relative flex items-center h-8 text-sm pl-8 pr-3 hover:bg-slate-300 cursor-pointer w-full">
                <.icon name="hero-plus" class="size-4 relative top-px" />
                <span class="ml-2 leading-none">Add rooms</span>
                <div class="hidden group-hover:block cursor-default absolute top-8 right-2 bg-white border-slate-200 border py-3 rounded-lg">
                  <div class="w-full text-left">
                    <div class="hover:bg-sky-600">
                      <div
                        phx-click={JS.navigate(~p"/rooms/#{@room}/new")}
                        class="cursor-pointer whitespace-nowrap text-gray-800 hover:text-white px-6 py-1 block"
                      >
                        Create a new room
                      </div>
                    </div>

                    <div class="hover:bg-sky-600">
                      <div
                        phx-click={JS.navigate(~p"/rooms")}
                        class="cursor-pointer whitespace-nowrap text-gray-800 hover:text-white px-6 py-1"
                      >
                        Browse rooms
                      </div>
                    </div>
                  </div>
                </div>
              </button>
            </div>

            <div class="mt-4">
              <div class="flex items-center h-8 px-3 group">
                <div class="flex items-center flex-grow focus:outline-none">
                  <.toggler on_click={toggle_users()} dom_id="users-toggler" text="Users" />
                </div>
              </div>
              <div id="users-list">
                <.user
                  :for={user <- @users}
                  user={user}
                  online={OnlineUsers.online?(@online_users, user.id)}
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="flex flex-col flex-grow">
        <div class="flex justify-between items-center flex-shrink-0 h-16 bg-white border-b border-slate-300 px-4">
          <%!-- Hamburger menu button --%>
          <button
            class="lg:hidden rounded-md text-gray-600 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-slate-500"
            phx-click="toggle-mobile-sidebar"
          >
            <span class="sr-only">Open sidebar</span>
            <.icon name="hero-bars-3" class="h-6 w-6" />
          </button>

          <div class="flex flex-col gap-1.5">
            <h1 class="text-sm font-bold leading-none">
              #<%= @room.name %>

              <.link
                :if={@joined?}
                class="font-normal text-xs text-blue-600 hover:text-blue-700"
                navigate={~p"/rooms/#{@room}/edit"}
              >
                Edit
              </.link>
            </h1>
            <div class="text-xs leading-none h-3.5" phx-click="toggle-topic">
              <%= if @hide_topic? do %>
                <span class="text-slate-600">[Topic Hidden]</span>
              <% else %>
                <%= @room.topic %>
              <% end %>
            </div>
          </div>

          <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
            <%= if @current_user do %>
              <li class="text-[0.8125rem] leading-6 text-zinc-900">
                <%= @current_user.username %>
              </li>
              <li>
                <.link
                  href={~p"/users/settings"}
                  class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
                >
                  Settings
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/users/log_out"}
                  method="delete"
                  class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
                >
                  Log out
                </.link>
              </li>
            <% else %>
              <li>
                <.link
                  href={~p"/users/register"}
                  class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
                >
                  Register
                </.link>
              </li>
              <li>
                <.link
                  href={~p"/users/log_in"}
                  class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
                >
                  Log in
                </.link>
              </li>
            <% end %>
          </ul>
        </div>

        <div
          class="flex flex-col flex-grow overflow-auto"
          id="room-messages"
          phx-update="stream"
          phx-hook="RoomMessages"
        >
          <%= for {dom_id, message} <- @streams.messages do %>
            <%= if message == :unread_marker do %>
              <div id={dom_id} class="w-full flex text-red-500 items-center gap-3 pr-5">
                <div class="w-full h-px grow bg-red-500"></div>
                <div class="text-sm">New</div>
              </div>
            <% else %>
              <.message
                current_user={@current_user}
                dom_id={dom_id}
                message={message}
                timezone={@timezone}
              />
            <% end %>
          <% end %>
        </div>

        <div :if={@joined?} class="h-12 bg-white px-4 pb-4">
          <.form
            id="new-message-form"
            for={@new_message_form}
            phx-change="validate-message"
            phx-submit="submit-message"
            class="flex items-center border-2 border-slate-300 rounded-sm p-1"
          >
            <textarea
              class="flex-grow text-sm px-3 border-l border-slate-300 mx-1 resize-none"
              cols=""
              id="chat-message-textarea"
              name={@new_message_form[:body].name}
              placeholder={"Message ##{@room.name}"}
              phx-debounce
              rows="1"
              phx-hook="ChatMessageTextarea"
            ><%= Phoenix.HTML.Form.normalize_value("textarea", @new_message_form[:body].value) %></textarea>
            <button class="flex-shrink flex items-center justify-center h-6 w-6 rounded hover:bg-slate-200">
              <.icon name="hero-paper-airplane" class="h-4 w-4" />
            </button>
          </.form>
        </div>

        <div
          :if={!@joined?}
          class="flex justify-around mx-5 mb-5 p-6 bg-slate-100 border-slate-300 border rounded-lg"
        >
          <div class="max-w-3xl text-center">
            <div class="mb-4">
              <h1 class="text-xl font-semibold">#<%= @room.name %></h1>
              <p class="text-sm mt-1 text-gray-600"><%= @room.topic %></p>
            </div>
            <div class="flex items-center justify-around">
              <button
                phx-click="join-room"
                class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-500 focus:outline-none focus:ring-2 focus:ring-green-500"
              >
                Join Room
              </button>
            </div>
            <div class="mt-4">
              <.link
                navigate={~p"/rooms"}
                href="#"
                class="text-sm text-slate-500 underline hover:text-slate-600"
              >
                Back to All Rooms
              </.link>
            </div>
          </div>
        </div>
      </div>

      <.modal
        id="new-room-modal"
        show={@live_action == :new}
        on_cancel={JS.navigate(~p"/rooms/#{@room}")}
      >
        <.header>New chat room</.header>
        <.room_form form={@new_room_form} />
      </.modal>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    ChatRoomEventHandlers.handle_mount(socket)
  end

  @impl true
  def handle_params(params, _url, socket) do
    ChatRoomEventHandlers.handle_initial_params(params, socket)
  end

  @impl true
  def handle_event("submit-message", %{"message" => message_params}, socket) do
    ChatRoomEventHandlers.handle_submit_message(message_params, socket)
  end

  @impl true
  def handle_event("toggle-topic", _unsigned_params, socket) do
    ChatRoomEventHandlers.handle_toggle_topic(socket)
  end

  @impl true
  def handle_event("validate-message", %{"message" => message_params}, socket) do
    ChatRoomEventHandlers.handle_validate_message(message_params, socket)
  end

  @impl true
  def handle_event("validate-room", %{"room" => room_params}, socket) do
    ChatRoomEventHandlers.handle_validate_room(room_params, socket)
  end

  @impl true
  def handle_event("save-room", %{"room" => room_params}, socket) do
    ChatRoomEventHandlers.handle_save_room(room_params, socket)
  end

  @impl true
  def handle_event("delete-message", %{"id" => id}, socket) do
    ChatRoomEventHandlers.handle_delete_message(id, socket)
  end

  @impl true
  def handle_event("join-room", _, socket) do
    ChatRoomEventHandlers.handle_join_room(socket)
  end

  @impl true
  def handle_event("toggle-mobile-sidebar", _, socket) do
    {:noreply, assign(socket, show_mobile_sidebar?: !socket.assigns.show_mobile_sidebar?)}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    ChatRoomEventHandlers.handle_new_message(message, socket)
  end

  @impl true
  def handle_info({:message_deleted, message}, socket) do
    ChatRoomEventHandlers.handle_delete_message(message.id, socket)
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    ChatRoomEventHandlers.handle_presence_diff(diff, socket)
  end

  defp toggle_rooms() do
    JS.toggle(to: "#rooms-toggler-chevron-down")
    |> JS.toggle(to: "#rooms-toggler-chevron-right")
    |> JS.toggle(to: "#rooms-list")
  end

  defp toggle_users() do
    JS.toggle(to: "#users-toggler-chevron-down")
    |> JS.toggle(to: "#users-toggler-chevron-right")
    |> JS.toggle(to: "#users-list")
  end
end
