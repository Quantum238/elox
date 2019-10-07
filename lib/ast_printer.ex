defmodule ASTPrinter do
	alias GrammarExpr

	def print(expr) do
		IO.puts GrammarExpr.accept(expr, &ASTPrinter.visit/1)
	end


	def visit(expr) do
		expr_type = GrammarExpr.get(expr, :expr_type)
		case expr_type do
			:binary -> 
				GrammarExpr.get(expr, :operator)
				|> Token.get(:lexeme)
				|> parenthesize([GrammarExpr.get(expr, :left), GrammarExpr.get(expr, :right)])
			:grouping ->
				parenthesize("group", [GrammarExpr.get(expr, :expression)])
			:literal ->
				cond do
					GrammarExpr.get(expr, :value) == nil -> "nil"
					true -> GrammarExpr.get(expr, :value)
				end
			:unary ->
				GrammarExpr.get(expr, :operator)
				|> Token.get(:lexeme)
				|> parenthesize([GrammarExpr.get(expr, :right)])

		end
	end


	def parenthesize(name, exprs) do
		stringified = "(#{name}"
		stringified = Enum.reduce(
			exprs,
			stringified,
			fn(expr, acc) ->
				acc <> " #{GrammarExpr.accept(expr, &ASTPrinter.visit/1)}"
			end 
		)
		stringified = stringified <> ")"
	end
end
