names = assign(:children)
name = assign(:name)
    
object(:person) do
    property :name, name 
    object(:work, %{name: "Development"})
    array(:children, names) do
    	%{name: item}
    end
end    
