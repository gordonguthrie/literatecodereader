defmodule LiterateCompiler.Languages.Erlang do

### Purpose

## Processes Erlang files

#### Public API

## The fixed API could have been enforced as a [behaviour](https://hexdocs.pm/elixir/1.4.5/behaviours.html)
## but that's a bit over the top

##       _   _       _     ______ _       _     _              _
##      | \ | |     | |   |  ____(_)     (_)   | |            | |
##      |  \| | ___ | |_  | |__   _ _ __  _ ___| |__   ___  __| |
##      | . ` |/ _ \| __| |  __| | | '_ \| / __| '_ \ / _ \/ _` |
##      | |\  | (_) | |_  | |    | | | | | \__ \ | | |  __/ (_| |
##      |_| \_|\___/ \__| |_|    |_|_| |_|_|___/_| |_|\___|\__,_|

	def is_comment(line) do
		IO.inspect(line, label: "is comment")
	end

	def comment_level(_), do: 0

	def get_js_ext, do: "erlang"

end