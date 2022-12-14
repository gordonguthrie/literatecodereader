defmodule LiterateCompiler.Extensions do

	def get_comment_marker(".erl"), do: "%"
	def get_comment_marker(".hrl"), do: "%"
	def get_comment_marker(".xrl"), do: "%"
	def get_comment_marker(".yrl"), do: "%"
	def get_comment_marker(".ex"),  do: "#"
	def get_comment_marker(".exs"), do: "#"
	def get_comment_marker(_),      do: :none

end