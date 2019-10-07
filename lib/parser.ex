defmodule parser do
	alias GrammarExpr
	alias Lox
	
	def init(tokens) do
		Agent.start_link(
			fn -> {
				tokens: tokens,
				current: 0,
			} end,
			name: __MODULE__)
		pid
	end

	def get(key) do
		Agent.get(__MODULE__, fn(self) -> self[key] end)
	end

	def update(key, val) do
		Agent.update(__MODULE__, fn(self) -> Map.put(self, key, val) end)
	end


	defp match(token_types) do
		case token_types do
			[head_token | rest] ->
				if check(type) do
					advance()
					true
				end
				match(rest)
			_ -> false
		end
	end

	defp check(token_type) do
		if isAtEnd() do
			false
		else
			Token.get(peek(), :type) == token_type
		end
	end

	defp advance do
		if !isAtEnd() do
			update(:current, get(:current) + 1)
		end
		previous()
	end

	defp isAtEnd do
		Token.get(peek(), :type) == :EOF
	end

	defp peek do
		get(:tokens)
		|> Enum.at(get(:current))
	end

	defp previous do
		get(:tokens)
		|> Enum.at(get(:current) - 1)
	end

	defp consume(token_type, message) do
		if check(token_type) do
			{:ok, advance()}
		else
			error(peek(), message)
			{:error}
		end
	end

	defp error(token, message) do
		Lox.error(token, message)
	end

	defp synchronize_helper do
		if !isAtEnd() do
			last_was_semicolon = Token.get(previous(), :type) == :SEMICOLON
			keyword_list = [
				:CLASS,
				:FUN,
				:VAR,
				:FOR,
				:IF,
				:WHILE,
				:PRINT,
				:RETURN
			]
			next_type = Token.get(peek(), :type)
			next_is_keyword = Enum.member?(keyword_list, next_type)
			if !last_was_semicolon and !next_is_keyword do
				advance()
				synchronize_helper()
			end
		end
	end
	defp synchronize do
		advance()
		synchronize_helper()
	end




	# actual productions
	defp expression do
		equality()
	end


	defp equality_helper(expr) do
		operator = previous()
		right = comparison()
		if match([:BANG_EQUAL, :EQUAL_EQUAL]) do
			expr = GrammarExpr.binary(expr, operator, right)
			equality_helper(expr)
		else
			expr
		end
	end
	defp equality do
		expr = comparison()
		equality_helper(expr)
	end

	defp comparison_helper(expr) do
		operator = previous()
		right = addition()
		if match([:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL]) do
			expr = GrammarExpr.binary(expr, operator, right)
			comparison_helper(expr)
		else
			expr
		end

	end
	defp comparison do
		expr = addition()
		comparison_helper(expr)
	end

	defp addition_helper(expr) do
		operator = previous()
		right = multiplication()
		if match([:MINUS, :PLUS]) do
			expr = GrammarExpr.binary(expr, operator, right)
			addition_helper(expr)
		else
			expr
		end
	end
	defp addition do
		expr = multiplication()
		addition_helper(expr)
	end

	defp multiplication_helper(expr) do
		operator = previous()
		right = unary()
		if match([:SLASH, :STAR]) do
			expr = GrammarExpr.binary(expr, operator, right)
		else
			expr
		end
	end
	defp multiplication do
		expr = unary()
		multiplication_helper(expr)
	end

	defp unary do
		if match([:BANG, :MINUS]) do
			operator = previous()
			right = unary()
			GrammarExpr.unary(operator, right)
		else
			primary()
		end
	end

	defp primary do
		cond do
			match([:FALSE]) -> GrammarExpr.literal(false)
			match([:TRUE]) -> GrammarExpr.literal(true)
			match([:NIL]) -> GrammarExpr.literal(nil)
			match([:NUMBER, :STRING]) -> GrammarExpr.literal(Token.get(previous(), :literal))
			match([:LEFT_PAREN]) ->
				expr = expression()
				case consume(:RIGHT_PAREN, "Expect ')' after expression.") do
					{:ok, _} -> GrammarExpr.grouping(expr)
					{:error} -> raise "ParseError"
				end
			error(peek(), "Expect expression.")
			raise "Parse Error"
		end
	end

	def parse do
		try do
			expression()
		rescue
			nil
		end
	end

end