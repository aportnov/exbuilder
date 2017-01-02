defmodule ExBuilder.XML.Element do
	@moduledoc """
		Set of funtions to convert Map key => value into `xmerl` tuples.
	"""

	@doc ~S"""
		Convert named Map into `xmerl` tuple
		
		##Example:
			iex> ExBuilder.XML.Element.element(:sample, %{name: "Name"})  
			{:sample, [name: "Name"], []}
			
			iex> ExBuilder.XML.Element.element(:sample, %{name: "Name", children: [%{name: "Child"}]})
			{:sample, [name: "Name"], [{:children, [], [{:child, [name: "Child"], []}]}]}
	"""
	def element(name, %{} = values) do
		fun = fn({_k, %{}}) -> true
						({_k, [] }) -> true
						({_k, [%{}| _]}) -> true
						({_k, _v}) -> false
		end
		
		{nodes, attributes} = Enum.partition(values, fun)
		
		children = nodes |> Enum.sort |> Enum.map(fn({k, v}) -> element(k, v) end)
		
		{node_name(name), attributes, children}
	end
	
	@doc ~S"""
		Convert named List into `xmerl` tuple
		
		##Example:
			iex> ExBuilder.XML.Element.element(:children, [%{name: "Child"}]) 
			{:children, [], [{:child, [name: "Child"], []}]}
			
			iex> ExBuilder.XML.Element.element(:children, []) 
			{:children, [], []}
	"""
	def element(name, values) when is_list(values) do
		wrapper_name = node_name(name)
		element_name = Inflex.singularize(wrapper_name)
		
		{wrapper_name, [], Enum.map(values, fn(%{} = item) -> element(element_name, item) end)}
	end
	
	defp node_name(value) when is_atom(value), do: value
	defp node_name(value) when is_binary(value), do: String.to_atom(value)

	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__), only: [element: 2]
		end
	end
end

defmodule ExBuilder.XML.Encoder do
	@moduledoc """
		Set of functions to convert Map into XML document
	"""
	use ExBuilder.XML.Element
	
	@doc ~S"""
		Encode single element Map into XML as a root element
		
		##Example:
			iex> ExBuilder.XML.Encoder.encode(%{sample: %{name: "Name"}})  
			'<?xml version="1.0"?><sample name="Name"/>'
			
			iex> ExBuilder.XML.Encoder.encode(%{sample: %{name: "Name", children: [%{name: "Child"}]}})
			'<?xml version="1.0"?><sample name="Name"><children><child name="Child"/></children></sample>'
	"""
	def encode(%{} = data) when map_size(data) == 1 do
		[{root_element, values}] = Map.to_list(data)
		encode(values, root_element)
	end

	@doc ~S"""
		Encode Map into XML, wrapping with root element
		
		##Example:
			iex> ExBuilder.XML.Encoder.encode(%{name: "Name"}, :sample)  
			'<?xml version="1.0"?><sample name="Name"/>'
			
			iex> ExBuilder.XML.Encoder.encode(%{name: "Name", children: [%{name: "Child"}]}, :sample)
			'<?xml version="1.0"?><sample name="Name"><children><child name="Child"/></children></sample>'
	"""
	def encode(%{} = data, root_element) do
		:xmerl.export_simple([element(root_element, data)], :xmerl_xml) |> List.flatten
	end
	
	defmacro __using__(_options) do
		quote do
			import unquote(__MODULE__)
		end
	end
	
end