defmodule Elox do
  alias Scanner
  alias Lox
  alias GrammarExpr
  alias Parser
  alias Interpreter
  @moduledoc """
  Documentation for Elox.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elox.hello()
      :world

  """
  def main(args) do
    options = [switches: [file: :string], aliases: [f: :file]]
    {opts, _, _} = OptionParser.parse(args, options)
    IO.inspect opts, label: "Command Line Arguments"
    IO.puts length(opts)

    cond do
      length(opts) > 1 ->
        IO.puts "Usage: elox [script]"
        System.halt(64)
      length(opts) == 1 ->
        Lox.init()
        runFile(opts[:file])
      true ->
        Lox.init()
        runPrompt()
    end

    # DELME
    expression = GrammarExpr.binary(
        GrammarExpr.unary(
          Token.init(:MINUS, "-", nil, 1),
          GrammarExpr.literal(123)
        ),
        Token.init(:STAR, "*", nil, 1),
        GrammarExpr.grouping(
          GrammarExpr.literal(45.67)
        )
      )
    ASTPrinter.print(expression)
    # End DELME
  end


  defp run(source) do
    if Lox.hadError do
      System.halt(65)
    end
    if Lox.hadRuntimeError do
      System.halt(70)
    end
    Scanner.init(source)
    tokens = Scanner.scanTokens()
    Parser.init(tokens)
    expression = Parser.parse()
    if Lox.hadError do
      nil
    else
      # IO.puts(ASTPrinter.print(expression))
      Interpreter.interpret(expression)
    end


  end

  defp runFile(path) do
    IO.puts "Running File #{path}"
    _file = File.open!(path, [:read, :utf8])
    contents = File.read!(path)
    IO.puts "File says #{contents}"
    File.close(path)
    run(contents)
  end

  defp runPrompt do
    IO.puts "Running Interactively"
    input = IO.gets "> "
    run(input)
    Lox.clearError()
    runPrompt()
  end

  
end
