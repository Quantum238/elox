defmodule Token do
	use Agent


	def init(type, lexeme, literal, line) do
		{:ok, pid} = Agent.start_link(fn -> %{
			type: type,
			lexeme: lexeme,
			literal: literal,
			line: line
			} end
		)
		pid
	end

	def toString(pid) do
		token_info = Agent.get(pid, fn(self) -> self end)
		"#{token_info.type} #{token_info.lexeme} #{token_info.literal}"
	end
	
end
