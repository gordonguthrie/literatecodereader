defmodule LiterateCompiler.Outputter.HTML do

	def format(:markdown, contents, _language) do
		:markdown.conv_utf8(contents)
	end
	def format(:code, contents, language) do
		js_extension = Kernel.apply(language, :get_js_ext, [])
		Enum.join(["<pre class=\"", js_extension, "\">\n", contents, "</pre>\n"])
	end

end