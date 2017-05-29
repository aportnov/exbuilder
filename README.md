# ExBuilder

Simple library to support Ruby style builder-like JSON and XML templates. 
Templates should be placed into web/templates directory in the root of the project and have builder extension. 
All templates will be compiled into functions and available via `ExBuilder.View` module. 

##### Passing Parameters

Parameters, passed to the generated function as a keyword list, are available inside template via assign/1 macro. 
For convenience, Eex style variables notation: @var_name, is supported and can be used inside templates in the same way `assign(var_name)` is used.

Following code samples produce identical outcome:

```elixir
iex>   name = assign(:name)	
iex>   property(:name, name)
``` 

```elixir
iex>   property(:name, @name)
``` 

##### Sample test cases:

```elixir
iex> document do
iex>	object(:sample, %{name: "Joe"})
iex> end
%{sample: %{name: "Joe"}}

iex> document do
iex>   name = assign(:name)	
iex>   property(:name, name)
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
```

##### Using `ExBuilder.View` with simple Plug application

1. Place following code into template file in web/templates/sample.builder.
   Note that Eex style variables @var_name is used inside templates in the same way `assign(var_name)` is used

```elixir
	names = assign(:children)

	object(:person) do
	    property :name, @name 
	    object(:company, @company)
	    array(:children, names) do
	    	%{name: item}
	    end
	end
```

2. Add use statement for `ExBuilder.View`

```elixir
	
	defmodule MyApp.Api do
		use Plug.Router

		plug :match
		plug :dispatch

		use ExBuilder.View
		
		get "/info.json" do
		
			send_resp(conn, 200, render_json("sample", name: "John Smith", children: ["Jeff"], company: %{name: "Company Name"}))
		end
	
		get "/info.xml" do
		
			send_resp(conn, 200, render_xml("sample", name: "John Smith", children: ["Jeff"], company: %{name: "Company Name"}))
		end
		
	end
	
```


## Installation

From [Hex](https://hex.pm/packages/exbuilder), the package can be installed as:

  1. Add `exbuilder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exbuilder, "~> 0.1"}]
end
```
