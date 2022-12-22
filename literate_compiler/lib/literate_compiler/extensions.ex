defmodule LiterateCompiler.Extensions do

### Purpose

## This module turns file system extension into module names for use
## in both the file processing and output parts of the script.

	def get_lang_module(".ex"),                  do: LiterateCompiler.Languages.Elixir_lang
	def get_lang_module(".exs"),                 do: LiterateCompiler.Languages.Elixir_lang
	def get_lang_module(".elixir_architecture"), do: LiterateCompiler.Languages.Elixir_lang
	def get_lang_module(".erl"),                 do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".hrl"),                 do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".xrl"),                 do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".yrl"),                 do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".erlang_architecture"), do: LiterateCompiler.Languages.Erlang
	def get_lang_module(".scd"),                 do: LiterateCompiler.Languages.SuperCollider
	def get_lang_module(".scd_tutorial"),        do: LiterateCompiler.Languages.SuperCollider
	def get_lang_module(".md"),                  do: LiterateCompiler.Languages.Markdown
	def get_lang_module(_),                      do: :none

	def get_formatter_module("md"),   do: LiterateCompiler.Outputter.Markdown
	def get_formatter_module("html"), do: LiterateCompiler.Outputter.HTML

end