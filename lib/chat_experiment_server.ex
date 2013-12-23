defmodule ChatServer do
	use GenServer.Behaviour

	def start_link(_options // []) do
		:gen_server.start_link({ :local, :chat_server }, __MODULE__, [], [])
	end

	def init(state), do: {:ok, state}	

	def handle_call({:join, room_name}, {from, _}, rooms) do
		{:ok, room_name} = String.to_char_list(room_name)
		room_name = list_to_atom(room_name)

		{room_name, room} = List.keyfind(rooms, room_name, 0, {room_name, HashSet.new()})
		room = HashSet.put(room, from)

		rooms = List.keystore(rooms, room_name, 0, {room_name, room})

		{:reply, nil, rooms}
	end

	def handle_call({:leave, room_name}, {from, _}, rooms) do
		{:ok, room_name} = String.to_char_list(room_name)
		room_name = list_to_atom(room_name)

		case List.keymember?(rooms, room_name, 0) do
			true ->
				{room_name, room} = List.keyfind(rooms, room_name, 0)
				room = HashSet.delete(room, from)

				from <- {:send_leave, room}

				case HashSet.size(room) do
					0 -> {:reply, nil, List.keydelete(rooms, room_name, 0)}
					_ -> {:reply, nil, List.keyreplace(rooms, room_name, 0, {room_name, room})}
				end
			_ -> {:reply, nil, rooms}
		end
	end
	
	def handle_call({:talk, room_name, username, message}, {from, _}, rooms) do
		{:ok, room_name} = String.to_char_list(room_name)
		room_name = list_to_atom(room_name)

		{_room_name, room} = List.keyfind(rooms, room_name, 0)

		Enum.each(room, fn(user) -> 
			if user != from do
				user <- {:got_message, username, message}
			end
		end)

		{:reply, nil, rooms}
	end

	def handle_call(_msg, _from, rooms) do
		IO.puts("Unhandled message")
		{:noreply, rooms}
	end
	
end