# ExBuilder

Simple library to support Ruby style jbuilder-like JSON templates. 
Templates should be placed into web/templates directory and have builder extension. 
All templates will be compiled into functions and available via `ExBuilder.Template` module. 
Parameters, passed to the generated function as a keyword list, are available inside template via assign/1 macro.

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

##### Using `ExBuilder.Template` with simple Plug application

1. Place following code into template file in web/templates/sample.builder

```elixir
	names = assign(:children)

	object(:person) do
	    property :name, assign(:name) 
	    object(:company, assign(:company))
	    array(:children, names) do
	    	%{name: item}
	    end
	end
```

2. Add use statement for `ExBuilder.Template`

```elixir
	
	defmodule MyApp.Api do
		use Plug.Router

		plug :match
		plug :dispatch

		use ExBuilder.Template
		
		get "/info" do
		
			send_resp(conn, 200, render_json("sample", name: "John Smith", children: ["Jeff"], company: %{name: "Company Name"}))
		end
	
	end
	
```


## Installation

From [Hex](https://hex.pm/packages/exbuilder), the package can be installed as:

  1. Add `exbuilder` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:exbuilder, "~> 0.1.0"}]
    end
    ```

  2. Ensure `exbuilder` is started before your application:

    ```elixir
    def application do
      [applications: [:exbuilder]]
    end
    ```

