defmodule Scanner do
	use Agent
	alias Token
	alias Lox

	def init(source) do
		split_source = String.codepoints(source)
		Agent.start_link(fn -> %{
			source: split_source,
			orig_length: length(split_source),
			tokens: [],
			start: 0,
			current: 0,
			line: 1,
			lox: Lox.init(),
			} end,
			name: __MODULE__
		)
	end

	def get(val) do
		Agent.get(__MODULE__, fn(self) -> self[val] end)
	end

	def update(key, new_val) do
		Agent.update(__MODULE__, fn(self) -> Map.put(self, key, new_val) end)
	end

	def scanTokens do
		cond do
			isAtEnd() ->
				line = get(:line)
				new_token = Token.init(:EOF, "", nil, line)
				cur_tokens = get(:tokens)
				update(:tokens, cur_tokens ++ [new_token])
				get(:tokens)
			true ->
				update(:start, get(:current))
				scanToken()
				scanTokens()

		end
	end

	defp isAtEnd do
		get(:current) >= get(:orig_length)
	end

	defp advance do
		update(:current, get(:current) + 1)
		rest_of_source = get(:source) |> Enum.drop(get(:current)) |> Enum.take(1)
		case rest_of_source do
			[next_char | _]  -> next_char
			_ -> ""
		end
	end

	defp addToken(type) do
		addToken(type, nil)
	end
	defp addToken(type, literal) do
		text = 
			get(:source) |> 
			Enum.drop(get(:start)) |> 
			Enum.take(get(:current) - get(:start)) |> 
			Enum.join("")
		new_token = Token.init(type, text, literal, get(:line))
		update(:tokens, get(:tokens) ++ [new_token])
	end

	defp match(expected) do
		cond do
			isAtEnd() -> false
			Enum.drop(get(:source), get(:current)) |> Enum.take(1) != expected -> false
			true -> 
				update(:current, get(:current) + 1)
				true
		end
	end


	defp scanToken do
		c = advance()
		case c do
			"(" -> addToken(:LEFT_PAREN)
			")" -> addToken(:RIGHT_PAREN)
			"{" -> addToken(:LEFT_BRACE)
			"}" -> addToken(:RIGHT_BRACE)
			"," -> addToken(:COMMA)
			"." -> addToken(:DOT)
			"-" -> addToken(:MINUS)
			"+" -> addToken(:PLUS)
			";" -> addToken(:SEMICOLON)
			"*" -> addToken(:STAR)
			"!" -> addToken(if match("="), do: :BANG_EQUAL, else: :BANG)
			"=" -> addToken(if match("="), do: :EQUAL_EQUAL, else: :EQUAL)
			"<" -> addToken(if match("="), do: :LESS_EQUAL, else: :LESS)
			">" -> addToken(if match("="), do: :GREATER_EQUAL, else: :GREATER)
			_ -> Lox.error(get(:line), "Unexpected character.")
		end
	end
end
