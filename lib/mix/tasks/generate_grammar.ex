defmodule Mix.Tasks.GenerateGrammar do
	use Mix.Task

	@expr %{
		Binary: "left, operator, right",
		Grouping: "expression",
		Literal: "value",
		Unary: "operator, right",
	}

	def generate(base_name, type_map) do
		{:ok, file} = File.open(
			"lib/Grammar#{base_name}.ex",
			[:write, :utf8]
		)

		file_contents = ["
defmodule Grammar#{base_name} do
	use Agent
	alias Visit

	def init_#{String.downcase(base_name)}(state) do
		{:ok, pid} = Agent.start_link(fn -> state end)
		pid
	end

	def get(expr, key) do
		Agent.get(expr, fn(self) -> self[key] end)
	end

	def update(expr, key, value) do
		Agent.update(expr, fn(self) -> Map.put(self, key, value) end)
	end

	def accept(expr, visit_func) do
		visit_func.(expr)
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
					lower_case_name = Atom.to_string(class_name)
						|> String.downcase
					lower_case_atom_str = ":" <> lower_case_name
				class_def = ["
	def #{lower_case_name}(#{args}) do
		state = %{#{args_in_map}, expr_type: #{lower_case_atom_str}}
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
