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
		rest_of_source = get(:source) |> Enum.drop(get(:current)) |> Enum.take(1)
		update(:current, get(:current) + 1)
		case rest_of_source do
			[next_char | _]  -> next_char
			_ -> ""
		end
	end

	defp addToken(type) do
		addToken(type, nil)
	end

	defp getSourceSubstring(start, end_) do
		get(:source)
		|> Enum.drop(start)
		|> Enum.take(end_ - start)
		|> Enum.join("")
	end

	defp addToken(type, literal) do
		text = getSourceSubstring(get(:start), get(:current))
		new_token = Token.init(type, text, literal, get(:line))
		update(:tokens, get(:tokens) ++ [new_token])
	end

	defp getCurrentChar(offset \\ 0) do
		[char | _] = Enum.drop(get(:source), get(:current) + offset) |> Enum.take(1)
		char
	end
	defp match(expected) do
		cond do
			isAtEnd() -> 
				false
			getCurrentChar() != expected -> 
				false
			true -> 
				update(:current, get(:current) + 1)
				true
		end
	end

	defp advanceUntil(char) do
		if peek() != char and !isAtEnd() do
				advance()
				advanceUntil(char)
		end
	end

	defp peek do
		if isAtEnd() do
			"\0"
		else
			getCurrentChar()
		end
	end

	defp stringHelper do
		IO.puts "#{peek()} #{isAtEnd()}"
		if peek() != ~s(") and !isAtEnd() do
			if peek() == "\n" do
				update(:line, get(:line) + 1)
			end
			advance()
			stringHelper()
		end
	end
	defp string do

		stringHelper()
		# unterminated string
		if isAtEnd() do
			Lox.error(get(:line), "Unterminated string")
		else
			# eat the closing "
			advance()
			# trim off the surrounding "'s
			value = getSourceSubstring(get(:start) + 1, get(:current) - 1)
			IO.inspect value, label: "Adding the string token"
			addToken(:STRING, value)
		end
	end

	defp isDigit(c) do
		IO.inspect c, label: "is digit arg"
		case Float.parse(c) do
			 :error -> false
			 _ -> true
				
		end
	end

	defp peekNext() do
		if get(:current) + 1 >= get(:orig_length) do
			"\0"
		else
			getCurrentChar(1)
		end
	end

	defp numberHelper() do
		if isDigit(peek()) do
			advance()
			numberHelper()
		end
		
	end
	defp number() do

		numberHelper()
		# check to see if its a float
		if peek() == "." and isDigit(peekNext())do
			# eat the decimal point
			advance()
		end

		numberHelper()
		{value, _} = getSourceSubstring(get(:start), get(:current))
			|> Float.parse
		addToken(:NUMBER, value)
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
			"!" -> if match("=") do
				addToken(:BANG_EQUAL)
			else
				addToken(:BANG)
			end
				# addToken(if match("="), do: :BANG_EQUAL, else: :BANG)
			"=" -> 
				if match("=") do
					addToken(:EQUAL_EQUAL)
				else
					addToken(:EQUAL)
				end
				# addToken(if match("="), do: :EQUAL_EQUAL, else: :EQUAL)
			"<" -> addToken(if match("="), do: :LESS_EQUAL, else: :LESS)
			">" -> addToken(if match("="), do: :GREATER_EQUAL, else: :GREATER)
			"/" -> 
				if match("/") do
					advanceUntil("\n")
				else
					addToken(:SLASH)
				end
			" " -> nil
			"\r" -> nil
			"\t" -> nil
			"\n" -> update(:line, get(:line) + 1)
			~s(") -> string()
			_ ->
				if isDigit(c) do
					number()
				else
					Lox.error(get(:line), "Unexpected character.")
				end
		end
	end
end
