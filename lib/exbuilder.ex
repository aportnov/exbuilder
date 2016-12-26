require Template.Location

defmodule ExBuilder.Template do
	use Template.Location
	
	templates "web/templates", "builder"
	
	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
			@before_compile unquote(__MODULE__)
		end
	end
	
	defmacro __before_compile__(_env) do
		templates = find_templates
		
		ast = templates |> Enum.map(fn(path) -> compile(path) end)
		
		quote do
			unquote(ast)
		end
	end
	
	defp compile(path) do
		name = view_name(path)
		{:ok, body} = File.read(path)

		quote do
			@file unquote(path)
			@external_resource unquote(path)
			def unquote(name)(var!(assigns)) do
				_ = var!(assigns) 
				document do
					unquote(Code.string_to_quoted(body))
				end
			end
		end

	end

	# DSL Implementation

	defmacro document(do: block) do
		quote do
			var!(scope) = %{}
			unquote(block)
			var!(scope)
		end
	end

	defmacro assign(name) do
		quote do
			Keyword.get var!(assigns), unquote(name)
		end
	end

	defmacro object(name, do: block) do
		quote do: object(unquote(name), %{}, do: unquote(block))
	end
	
	defmacro object(name, attributes) do
		quote do: object(unquote(name), unquote(attributes), do: nil)
	end
	
	defmacro object(name, attributes, do: block) do
		quote do
			buffer = var!(scope)
			var!(scope) = unquote(attributes)
			unquote(block)
			var!(scope) = Map.merge(buffer, %{unquote(name) => var!(scope)})
		end
	end
	
	defmacro property(name, value) do
		quote do
			var!(scope) = Map.merge(var!(scope), %{unquote(name) => unquote(value)})
		end
	end

	defmacro array(name, list, do: block) do
		quote do
			values = Enum.map(unquote(list), fn(var!(item)) -> unquote(block) end)
			property(unquote(name), values)
		end
	end
end

defmodule ExBuilder.View do
	use ExBuilder.Template
	
	def render_json(path, assigns) do
		name = view_name(path)
		{:ok, json} = apply(__MODULE__, name, [assigns]) |> Poison.encode
		
		json
	end
	
	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
		end
	end
end