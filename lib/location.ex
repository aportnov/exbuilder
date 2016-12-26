defmodule Template.Location do
	defmacro templates(root, ext) do
		quote do
			@templates unquote(root)
			
			def view_name(@templates <> path), do: view_name(path)
			def view_name("/" <> path), do: view_name(path)
			def view_name(path) do
				path 
				|> String.downcase 
				|> String.replace("/", "_") 
				|> String.replace(".#{unquote(ext)}", "") 
				|> String.to_atom
			end

			defp find_templates(), do: find_templates(@templates)
			defp find_templates(root), do: Path.wildcard("#{root}/**/*.#{unquote(ext)}")
		end
	end

	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
		end
	end
end

