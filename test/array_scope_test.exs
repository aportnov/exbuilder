defmodule ExBuilderArrayTest do
  	use ExUnit.Case, async: true
    
    use ExBuilder.Template
    
    describe "Array scoping" do
      
      test "should allow for multiple array properties" do
        obj = document do
          object(:info, %{title: "Sample"})
          array(:first, ["Alex", "Danny"]) do
            %{name: item}
          end  
          
          array(:second, ["Developer", "Manager"]) do
            %{title: item}
          end
        end
        
        assert obj == %{
          info: %{title: "Sample"}, 
          first: [%{name: "Alex"}, %{name: "Danny"}],
          second: [%{title: "Developer"}, %{title: "Manager"}]
        }
      end
      
      test "should allow for array property inside an object" do
        obj = document do
          object(:info, %{title: "Sample"}) do
            array(:first, ["Alex", "Danny"]) do
              %{name: item}
            end  
          end
          
          array(:second, ["Developer", "Manager"]) do
            %{title: item}
          end
        end
        
        assert obj == %{
          info: %{title: "Sample", first: [%{name: "Alex"}, %{name: "Danny"}]}, 
          second: [%{title: "Developer"}, %{title: "Manager"}]
        }
      end
      
    end
    
end