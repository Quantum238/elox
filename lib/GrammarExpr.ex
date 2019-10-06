
defmodule GrammarExpr do
	use Agent

	def init_expr(state) do
		Agent.start_link(fn -> state end)
	end

	def get(expr, key) do
		Agent.get(expr, fn(self) -> self[key] end)
	end

	def update(expr, key, value) do
		Agent.update(expr, fn(self) -> Map.put(self, key, value) end)
	end

	def binary(left, operator, right) do
		state = %{left: left, operator: operator, right: right}
		init_expr(state)
	end

	def grouping(expression) do
		state = %{expression: expression}
		init_expr(state)
	end

	def literal(value) do
		state = %{value: value}
		init_expr(state)
	end

	def unary(operator, right) do
		state = %{operator: operator, right: right}
		init_expr(state)
	end
end
