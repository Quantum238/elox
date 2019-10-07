
defmodule GrammarExpr do
	use Agent
	alias Visit

	def init_expr(state) do
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

	def binary(left, operator, right) do
		state = %{left: left, operator: operator, right: right, expr_type: :binary}
		init_expr(state)
	end

	def grouping(expression) do
		state = %{expression: expression, expr_type: :grouping}
		init_expr(state)
	end

	def literal(value) do
		state = %{value: value, expr_type: :literal}
		init_expr(state)
	end

	def unary(operator, right) do
		state = %{operator: operator, right: right, expr_type: :unary}
		init_expr(state)
	end
end
