criteria = %{}

if @name == "Alex" do
  Map.put_new(criteria, :alex, "Alex")
end

object(:person) do
    if @name == "Alex" do
      property :name, @name 
    end
    object(:work, %{name: "Development"}) do
        object(:position, %{name: "Developer"}) do
            text(:travel, "some")
            property(:weekend, false)
        end
    end
    array(:friends, @names) do
    	%{name: item}
    end
    array(:kids, @children) do
    	%{name: item}
    end
end    
