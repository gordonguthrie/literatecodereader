defmodule LiterateCompiler.MixProject do
  use Mix.Project

  def project do
    [
      app: :literate_compiler,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: LiterateCompiler.CLI,
                comment: "an escript that compiles code to literal HTML for reading"],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:markdown, git: "https://github.com/hypernumbers/erlmarkdown", branch: "master"},
      {:phoenix_html, "~> 4.1.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
