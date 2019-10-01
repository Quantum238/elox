defmodule Elox do
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
        runFile(opts[:file])
      true ->
        runPrompt()
    end
  end


  def runFile(path) do
    IO.puts "Running File #{path}"
  end

  def runPrompt do
    IO.puts "Running Interactively"
  end





end
