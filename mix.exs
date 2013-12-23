defmodule ChatExperiment.Mixfile do
  use Mix.Project

  def project do
    [ app: :chat_experiment,
      version: "0.0.1",
      elixir: "~> 0.12.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ mod: {ChatExperiment, []},
      applications: [:cowboy]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:cowboy, "0.9.0",[github: "extend/cowboy", tag: "0.9.0"]},
      {:json, [github: "cblage/elixir-json"]}
    ]
  end
end
