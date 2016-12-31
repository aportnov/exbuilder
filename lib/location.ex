
defmodule Template.Location do
	@moduledoc """
		This module provides a convinience macro to generate support for template compilation
	"""
	
	defmacro templates(dir, ext) do
		root = full_path(dir)

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

	defp full_path(path) do
		:exbuilder
		|> Application.app_dir
		|> Path.split
		|> root_dir([])
		|> Path.join
		|> Path.join(path)
	end


	defp root_dir(["_build"| _], acc), do: Enum.reverse(acc)
	defp root_dir([h|t], acc), do: root_dir(t, [h | acc])

	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
		end
	end
end

