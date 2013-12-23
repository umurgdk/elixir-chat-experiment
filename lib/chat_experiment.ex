defmodule ChatExperiment do
    use Application.Behaviour   

    def start(_type, _args) do
        dispatch = :cowboy_router.compile([
            # {URIHost, list({URIPath, Handler, Opts})}
            {:_, [
                {"/socket", ChatExperiment.Handlers.ChatSocket, []},
                {"/assets/[...]", :cowboy_static, {:priv_dir, :chat_experiment, ""}},
                {"/", :cowboy_static, {:priv_file, :chat_experiment, "index.html"}}
            ]}
        ])

        case System.get_env("PORT") do
            nil ->  {:ok, _} = :cowboy.start_http(:http, 100,
                    [port: 8080],
                    [env: [dispatch: dispatch]])

            port -> {:ok, _} = :cowboy.start_http(:http, 100,
                    [port: binary_to_integer(port)],
                    [env: [dispatch: dispatch]])
        end

        IO.puts "Cowboy server running @ http://localhost:#{port}!"
        ChatServer.start_link
        ChatExperiment.Supervisor.start_link
    end
    
end
