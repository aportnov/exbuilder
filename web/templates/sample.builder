object(:person) do
    property :name, @name 
    object(:work, %{name: "Development"}) do
        object(:position, %{name: "Developer"})
    end
    array(:friends, @names) do
    	%{name: item}
    end
    array(:kids, @children) do
    	%{name: item}
    end
end    
