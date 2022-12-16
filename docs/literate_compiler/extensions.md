```elixirdefmodule LiterateCompiler.Extensions do

	def get_lang_module(".ex"),              do: LiterateCompiler.Languages.Elixir_lang
	def get_lang_module(".exs"),             do: LiterateCompiler.Languages.Elixir_lang
	def get_lang_module(".elixir_tutorial"), do: LiterateCompiler.Languages.Elixir_lang
	def get_lang_module(".erl"),             do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".hrl"),             do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".xrl"),             do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".yrl"),             do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".erlang_tutorial"), do: LiterateCompiler.Languages.Erlang
	def get_lang_module(_),                  do: :none

	def get_formatter_module("md"),   do: LiterateCompiler.Outputter.Markdown
	def get_formatter_module("html"), do: LiterateCompiler.Outputter.HTML

end```