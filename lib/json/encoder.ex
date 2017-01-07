defimpl Poison.Encoder, for: Tuple do
  alias Poison.Encoder

	def encode({:text, value}, options) do
		Encoder.encode(value, options)
	end

	def encode({:cdata, value}, options) do
		Encoder.encode(value, options)
	end

	def encode(tuple, options) do
		Encoder.Any.encode(tuple, options)
	end
	
end