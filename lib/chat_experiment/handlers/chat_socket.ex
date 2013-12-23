defmodule ChatExperiment.Handlers.ChatSocket do
    def init({:tcp, :http}, _req, _opts) do
        {:upgrade, :protocol, :cowboy_websocket}
    end

    def websocket_init(_transport_name, req, _opts) do
        {:ok, req, []}
    end
    
    def websocket_handle({:text, msg}, req, state) do
        case JSON.decode(msg) do
            {:ok, result} -> handle_message(result["message"], result["data"], req, state)
            _ -> {:ok, req, state}
        end
    end

    def websocket_handle(_data, req, state) do
        {:ok, req, state}
    end

    def websocket_info({:send_leave, room}, req, state) do
        Enum.each(room, fn (user) -> 
            {:username, username} = List.keyfind(state, :username, 0, {:username, "unnamed!"})
            user <- {:got_leave, username}
        end)

        {:ok, req, state}
    end

    def websocket_info({:got_leave, username}, req, state) do
        case JSON.encode([message: "leave", data: [username: username]]) do
            {:ok, reply} -> {:reply, {:text, reply}, req, state}
        end
    end     

    def websocket_info({:got_message, username, message}, req, state) do
        case JSON.encode([message: "message", data: [username: username, message: message]]) do
            {:ok, reply} -> {:reply, {:text, reply}, req, state}
        end
    end
    

    def websocket_info(_info, req, state) do
        {:ok, req, state}
    end
    
    def websocket_terminate(_reason, _req, _state), do: :ok

    defp handle_message("join", data, req, state) do
        :gen_server.call(:chat_server, {:join, data["room"]})

        state = List.keystore(state, :username, 0, {:username, data["username"]})
        state = List.keystore(state, :room, 0, {:room, data["room"]})

        {:ok, req, state}
    end

    defp handle_message("leave", _data, req, state) do
        {:room, room} = List.keyfind(state, :room, 0)

        :gen_server.call(:chat_server, {:leave, room})
        {:ok, req, state}
    end

    defp handle_message("talk", data, req, state) do
        {:room, room} = List.keyfind(state, :room, 0)
        {:username, username} = List.keyfind(state, :username, 0)

        :gen_server.call(:chat_server, {:talk, room, username, data["message"]})

        {:ok, req, state}
    end

    defp handle_message(_msg, _data, req, state) do
        IO.puts("it doesn't match any message handlerssssss")
        {:ok, req, state}
    end
    
end