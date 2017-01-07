require Template.Location

defmodule ExBuilder.Template do
	@moduledoc """
		DSL for building complex Map structures. This is very Ruby builder-like templating.
	"""
	
	use Template.Location
	
	templates "web/templates", "builder"
	
	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
			@before_compile unquote(__MODULE__)
		end
	end
	
	defmacro __before_compile__(_env) do
		templates = find_templates()
		
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
			@doc false
			def unquote(name)(var!(assigns)) when is_list(var!(assigns)) do
				_ = var!(assigns) 
				document do
					unquote(Code.string_to_quoted(body))
				end
			end
		end
	end
	
	defp postwalk({:@, [line: line], [{name, [line: line], nil}]}) do
		quote do: assign(unquote(name))
	end
	defp postwalk(ast), do: ast

	# DSL Implementation

	@doc ~S"""
		Document entry point. This macro is used as a wrapper for a document generation.
		
		##Example:
			iex> document do
			iex>   property(:name, "Alex")
			iex> end
			%{name: "Alex"}
	"""
	defmacro document(do: block) do

		quote do
			var!(scope) = %{}
			unquote(Macro.postwalk(block, &postwalk/1))
			var!(scope)
		end
	end

	@doc ~S"""
		Provides access to the variables inside 'assigns' variable in the caller's scope
		
		##Example:
		
			iex> var!(assigns) = [name: "Alex"]
			iex> document do
			iex>   name = assign(:name)	
			iex>   property(:name, name)
			iex> end
			%{name: "Alex"}
		
		To simplify access to the variables, Eex stype @var_name is supported to:
		
			iex> var!(assigns) = [name: "Alex"]
			iex> document do
			iex>   property(:name, @name)
			iex> end
			%{name: "Alex"}
			
	"""
	defmacro assign(name) do
		quote do
			Keyword.get var!(assigns), unquote(name)
		end
	end

	@doc ~S"""
		Provides access to the variables inside 'assigns' variable in the caller's scope
		
		##Example:
			iex> document do
			iex>	object(:sample, %{name: "Joe"})
			iex> end
			%{sample: %{name: "Joe"}}
			
			iex> document do 
			iex>	object(:sample, %{name: "Joe"}) do
			iex>		object(:children) do
			iex>			object(:child, %{name: "Phil"})
			iex>		end
			iex>	end
			iex> end
			%{sample: %{name: "Joe", children: %{child: %{name: "Phil"}}}}
	"""
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
	
	@doc ~S"""
		Add a property to the object context
		
		##Example:
			iex> document do
			iex>   property(:name, "Joe")
			iex> end
			%{name: "Joe"}
	"""
	defmacro property(name, value) do
		quote do
			var!(scope) = Map.merge(var!(scope), %{unquote(name) => unquote(value)})
		end
	end
	
	defmacro text(name, value) do
		quote do: property(unquote(name), {:text, unquote(value)})
	end

	@doc ~S"""
		Add an array property to the object context by iterating on list param. 
		Each item in the given list param is available inside array block as an 'item' variable
		
		##Example:
			iex> document do
			iex>	object(:work, %{name: "Development"})
			iex>	array(:names, ["Joe", "Phil"]) do
			iex>		%{name: item}
			iex>	end
			iex> end
			%{work: %{name: "Development"}, names: [%{name: "Joe"}, %{name: "Phil"}] }

			iex> document do
			iex>	object(:work, %{name: "Development"})
			iex>	array(:names, nil) do
			iex>		%{name: item}
			iex>	end
			iex> end
			%{work: %{name: "Development"}, names: []}

			iex> document do
			iex>	object(:work, %{name: "Development"})
			iex>	array(:names, []) do
			iex>		%{name: item}
			iex>	end
			iex> end
			%{work: %{name: "Development"}, names: []}

	"""
	defmacro array(name, nil, do: block) do
		quote do: array(unquote(name), [], do: unquote(block))
	end
	
	defmacro array(name, list, do: block) do
		quote do
			values = Enum.map(unquote(list), fn(var!(item)) -> unquote(block) end)
			property(unquote(name), values)
		end
	end
end

defmodule ExBuilder.View do
	@moduledoc """
		This module should be included into application. 
		All templates are compiled into this module, with names based on a file location
		Example: healthcheck/status.builder => healthcheck_status
	"""
	
	use ExBuilder.Template
	
	alias ExBuilder.XML.Encoder
	
	def apply_template(path, assigns) do
		name = view_name(path)
		apply(__MODULE__, name, [assigns])
	end
	
	def render_json(path, assigns) do
		{:ok, json} = apply_template(path, assigns) |> Poison.encode

		json
	end

	def render_xml(path, assigns, root_element) do
			apply_template(path, assigns) |> Encoder.encode(root_element)
	end
	
	def render_xml(path, assigns) do
			apply_template(path, assigns) |> Encoder.encode
	end
	
	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
		end
	end
end