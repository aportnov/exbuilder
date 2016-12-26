names = assign(:names)
    
object(:work, %{name: "Development"})
array(:names, names) do
	%{name: item}
end