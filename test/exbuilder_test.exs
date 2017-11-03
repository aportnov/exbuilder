defmodule ExBuilderTest do
  	use ExUnit.Case, async: true

	use ExBuilder.Template
	
	doctest ExBuilder.Template

	describe "Single Object Builder" do

		test "it should create a simple object hash" do
			obj = document do
				object(:sample, %{name: "Alex"})
			end
			assert obj == %{sample: %{name: "Alex"}}
		end

		test "it should create a simple object hierarchy hash" do
			obj = document do 
				object(:sample, %{name: "Alex"}) do
					object(:children) do
						object(:child, %{name: "Danny"})
					end
				end
			end

			assert obj == %{sample: %{name: "Alex", children: %{child: %{name: "Danny"}}}}
		end

		test "it should create a simple object hierarchy with multiple children" do
			obj = document do 
				object(:sample, %{name: "Alex"}) do
					object(:child, %{name: "Danny"})
					object(:work, %{name: "Development"})
				end
			end

			assert obj == %{sample: %{name: "Alex", child: %{name: "Danny"}, work: %{name: "Development"}}}
		end

		test "it should add simple array property" do
			obj = document do
				object(:work, %{name: "Development"})
				property(:names, [%{name: "Alex"}, %{name: "Danny"}])
			end
			assert obj == %{work: %{name: "Development"}, names: [%{name: "Alex"}, %{name: "Danny"}] }
		end

		test "it should add simple array property from list" do
			obj = document do
				object(:work, %{name: "Development"})
				array(:names, ["Alex", "Danny"]) do
					%{name: item}
				end
			end
			assert obj == %{work: %{name: "Development"}, names: [%{name: "Alex"}, %{name: "Danny"}] }
		end
    
    test "it should allow to use if logic inside template" do
      list = [:one, :two]
      
      obj = document do
        condition = false
        
        if condition do
          object(:work, %{title: "Developer"})
        else
          object(:work, %{title: "QA"})
        end
        
        array(:numbers, list) do
          if item == :one do
            %{number: %{value: item}}
          end 
        end
      end
      
      assert obj == %{work: %{title: "QA"}, numbers: [%{number: %{value: :one}} ]}
    end

	end
end