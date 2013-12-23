defmodule ChatExperiment do
	use Application.Behaviour	

	def start(_type, _args) do
		port = 8080

		dispatch = :cowboy_router.compile([
			# {URIHost, list({URIPath, Handler, Opts})}
			{:_, [
				{"/socket", ChatExperiment.Handlers.ChatSocket, []},
				{"/assets/[...]", :cowboy_static, {:priv_dir, :chat_experiment, ""}},
				{"/", :cowboy_static, {:priv_file, :chat_experiment, "index.html"}}
			]}
		])

		{:ok, _} = :cowboy.start_http(:http, 100,
																	[port: port],
																	[env: [dispatch: dispatch]])

		IO.puts "Cowboy server running @ http://localhost:#{port}!"
		ChatServer.start_link
		ChatExperiment.Supervisor.start_link
	end
	
end
