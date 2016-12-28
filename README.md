# ExBuilder

Simple library to support Ruby style jbuilder-like JSON templates. 
All templates that match web/templates/**/*.builder will be compiled into functions and available via `ExBuilder.Template` module. 
Parameters, passed to the generated function as a keyword list, are available inside template via assign/1 macro.

```elixir
iex> document do
iex>	object(:sample, %{name: "Joe"})
iex> end
%{sample: %{name: "Joe"}}


iex> document do
iex>   name = assign(:name)	
iex>   property(:name, name)
iex> end

iex> document do 
iex>	object(:sample, %{name: "Joe"}) do
iex>		object(:children) do
iex>			object(:child, %{name: "Phil"})
iex>		end
iex>	end
iex> end
%{sample: %{name: "Joe", children: %{child: %{name: "Phil"}}}}
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

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

