defmodule Mix.Tasks.GenerateGrammar do
	use Mix.Task

	@expr %{
		Binary: "left, operator, right",
		Grouping: "expression",
		Literal: "value",
		Unary: "operator, right",
	}

	def generate(file, base_name, type_map) do
		{:ok, file} = File.open(
			"lib/Grammar#{base_name}.ex",
			[:write, :utf8]
		)

		file_contents = ["
defmodule Grammar#{base_name} do
	use Agent

	def init_#{String.downcase(base_name)}(state) do
		Agent.start_link(fn -> state end)
	end

	def get(expr, key) do
		Agent.get(expr, fn(self) -> self[key] end)
	end

	def update(expr, key, value) do
		Agent.update(expr, fn(self) -> Map.put(self, key, value) end)
	end
"]
		file_contents = Enum.reduce(
			type_map,
			file_contents,
			fn(
				{class_name, args}, acc) ->
					args_in_map = String.split(args, ", ")
					|> Enum.map(fn(arg) -> "#{arg}: #{arg}" end)
					|> Enum.join(", ")
				class_def = ["
	def #{String.downcase(Atom.to_string(class_name))}(#{args}) do
		state = %{#{args_in_map}}
		init_#{String.downcase(base_name)}(state)
	end
"
				]
				acc ++ class_def
			end
		)
		file_contents = file_contents ++ ["end\n"]
		Enum.each(file_contents, fn(glob) -> IO.write(file, glob) end)
		File.close(file)
	end

	def run(_) do
		generate("Expr", @expr)
	end

end
