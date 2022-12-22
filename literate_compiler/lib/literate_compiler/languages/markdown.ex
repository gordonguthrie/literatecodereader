defmodule LiterateCompiler.Languages.Markdown do

### Purpose

## Processes Markdown files as input

# This allows you to mix markdown documentation with source code
# markdown proper is a bit easier on the eye than markdown-in-comments.
# However you lose the language type so any embedded code snippets aren't marked up
# swings meet roundabouts

#### Public API

## The fixed API could have been enforced as a [behaviour](https://hexdocs.pm/elixir/1.4.5/behaviours.html)
## but that's a bit over the top

	def is_comment(line), do: {{:comment, :line}, line}

	def comment_level({:comment, _}), do: 0

	def get_css_ext, do: ""

end