```elixirdefmodule LiterateCompiler.Outputter.HTML do

	def format(:markdown, contents, _language) do
		:markdown.conv_utf8(contents)
	end
	def format(:code, contents, language) do
		js_extension = Kernel.apply(language, :get_js_ext, [])
		Enum.join(["<pre class=\"", js_extension, "\"><code>\n", contents, "</code></pre>\n"])
	end

	def wrap(contents) do
		Enum.join([
					"<html>\n",
					"<head>\n",
					css(),
					"</head>\n",
					"<body>\n",
					contents,
					"</body>\n",
					"</html>"
				])
	end

	defp css() do```

```elixir<style>
html, body {
    padding: 2.5em;
    margin: auto;
    max-width: 48em;
}

body {
    font: 1.3em Palatino, Times;
    color: #333;
    line-height: 1.3;
    text-align: justify;
}

img {
    max-width: 100%;
}

table {
    border-collapse: collapse;
    margin-block-end: 1em;
}

th, td {
    padding: 0.5em 0.5em 0.25em;
    border: 1px solid #DDD;
}

th {
    border-bottom-width: 1.5px;
}

h1, h2, h3, h4, h5, h6 {
    page-break-after: avoid;
}

/* Typography
-------------------------------------------------------- */

h1 {
    margin-top: 0;
    font-weight: normal;
    text-align: center;
}

h2 {
    font-weight: normal;
    margin-top: 3em;
}

h3 {
    font-weight: normal;
    font-style: italic;
    margin-top: 3em;
}

p {
    margin-top: 0;
    -webkit-hypens: auto;
    -moz-hypens: auto;
    hyphens: auto;
}

ul {
    list-style: square;
    padding-left: 1.2em;
}

ol {
    padding-left: 1.2em;
}

blockquote {
    margin-left: 1em;
    padding-left: 1em;
    border-left: 1px solid #DDD;
}

code {
    font-family: "Consolas", "Menlo", "Monaco", monospace, serif;
    font-size: 0.9em;
}

a {
    color: #2484c1;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

a img {
    border: none;
}

h1 a, h1 a:hover {
    color: #333;
    text-decoration: none;
}

hr {
    color: #DDD;
    height: 1px;
    margin: 2em 0;
    border-top: solid 1px #DDD;
    border-bottom: none;
    border-left: 0;
    border-right: 0;
}


/* Small screens
-------------------------------------------------------- */

@media only screen and (max-width: 576px) {
    html, body {
        padding-left: 1.2em;
        padding-right: 1.2em;
    }

    body {
        text-align: left;
    }
}

/* Code Formatting
-------------------------------------------------------- */

pre[class*="language-"] {
    overflow-wrap: break-word;
}
</style>```

```elixirend

end```
