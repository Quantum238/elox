defmodule LoxRuntimeError do
	defexception [:message, :token]

end

defmodule Interpreter do
	alias GrammarExpr
	alias Token
	alias Lox

	def interpret(expression) do
		try do
			value = evaluate(expression)
			IO.inspect stringify(value)
		rescue
			e in LoxRuntimeError -> Lox.runtimeError(e)
		end
	end

	defp stringify(val) do
		IO.inspect(val)
	end

	def visit(expr) do
		expr_type = GrammarExpr.get(expr, :expr_type)
		case expr_type do
			:literal -> GrammarExpr.get(expr, :value)
			:grouping -> evaluate(GrammarExpr.get(expr, :expression))
			:unary -> 
				right = evaluate(GrammarExpr.get(expr, :right))
				op_type = GrammarExpr.get(expr, :operator) 
					|> Token.get(:type)
				case op_type do
					:MINUS -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperand(right)
						-1 * right
					:BANG -> !isTruthy(right)
					_ -> right
				end
			:binary ->
				left = evaluate(GrammarExpr.get(expr, :left))
				right = evaluate(GrammarExpr.get(expr, :right))
				op_type = GrammarExpr.get(expr, :operator)
				case op_type do
					:MINUS -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left - right
					:SLASH -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left / right
					:STAR -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left * right
					:PLUS ->
						cond do
							is_number(left) && is_number(right) ->
								left + right
							is_binary(left) && is_binary(right) ->
								left <> right
							true -> raise %LoxRuntimeError{
								token: GrammarExpr.get(expr, :operator),
								message: "Operands must both be numbers or both be strings"
							}
						end
					:GREATER -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left > right
					:GREATER_EQUAL -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left >= right
					:LESS -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left < right
					:LESS_EQUAL -> 
						GrammarExpr.get(expr, :operator)
							|> checkNumberOperands(left, right)
						left <= right
					:BANG_EQUAL -> !isEqual(left, right)
					:EQUAL_EQUAL -> isEqual(left, right)
				end

			_ -> nil
		end
	end

	def evaluate(expr) do
		GrammarExpr.accept(expr, &Interpreter.visit/1)
	end

	defp checkNumberOperand(operator, operand) do
		cond do
			is_number(operand) -> nil
			true -> raise %LoxRuntimeError{
				token: operator,
				message: "Operand must be number"
			}
		end
	end
	defp checkNumberOperands(operator, left, right) do
		cond do
			is_number(left) and is_number(right) -> nil
			true -> raise %LoxRuntimeError{
				token: operator,
				message: "Operands must be numbers"
			}
				
		end
	end
	defp isTruthy(val) do
		cond do
			val == nil -> false
			is_boolean(val) -> val
			true -> true
		end
	end

	defp isEqual(left, right) do
		cond do
			left == nil and right == nil -> true
			left == nil -> false
			true -> left == right
		end
	end
end
