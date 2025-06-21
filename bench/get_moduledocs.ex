defmodule Bench.GetModuledocs do
  @moduledoc ~S"""
  Compare runtime of line scanner amongst different branches
  """

  @modules [
    Access,
    Agent,
    Application,
    ArgumentError,
    ArithmeticError,
    Atom,
    BadArityError,
    BadBooleanError,
    BadMapError,
    Base,
    Bitwise,
    Calendar,
    Calendar.ISO,
    Calendar.TimeZoneDatabase,
    CaseClauseError,
    Code,
    Code.Fragment,
    Code.LoadError,
    Collectable,
    CompileError,
    CondClauseError,
    Config,
    Config.Provider,
    Config.Reader,
    Date,
    Date.Range,
    DateTime,
    Duration,
    DynamicSupervisor,
    Enum,
    Enum.EmptyError,
    Enum.OutOfBoundsError,
    Enumerable,
    Exception,
    File,
    File.CopyError,
    File.Error,
    File.LinkError,
    File.RenameError,
    File.Stat,
    File.Stream,
    Float,
    Function,
    FunctionClauseError,
    GenServer,
    IO,
    IO.ANSI,
    IO.Stream,
    Inspect,
    Inspect.Algebra,
    Inspect.Error,
    Inspect.Opts,
    Integer,
    JSON,
    JSON.DecodeError,
    JSON.Encoder,
    Kernel.ParallelCompiler,
    Kernel.TypespecError,
    KeyError,
    Keyword,
    List,
    List.Chars,
    Macro,
    Macro.Env,
    Map,
    MapSet,
    MatchError,
    MismatchedDelimiterError,
    MissingApplicationsError,
    Module,
    NaiveDateTime,
    Node,
    OptionParser,
    OptionParser.ParseError,
    PartitionSupervisor,
    Path,
    Port,
    Process,
    Protocol,
    Protocol.UndefinedError,
    Range,
    Record,
    Regex,
    Regex.CompileError,
    Registry,
    RuntimeError,
    Stream,
    String,
    String.Chars,
    StringIO,
    Supervisor,
    SyntaxError,
    System,
    System.EnvError,
    SystemLimitError,
    Task,
    Task.Supervisor,
    Time,
    TokenMissingError,
    TryClauseError,
    Tuple,
    URI,
    URI.Error,
    UndefinedFunctionError,
    Version,
    Version.InvalidRequirementError,
    Version.InvalidVersionError,
    Version.Requirement,
    WithClauseError,
    ]

  @doc ~S"""
  Load all moduledocs of the elixir library
  """
  def load_moduledocs do
    @modules 
    |> Stream.flat_map(&load_moduledoc/1)
    |> Enum.with_index 
  end

  defp load_moduledoc(module) do
    eol = ~r/\n\r?/
      Code.ensure_loaded(module)
    case Code.fetch_docs(module) do
      {_, _, :elixir, "text/markdown", %{"en" => moduledoc}, _, _} -> moduledoc |> String.split(eol)
      _ -> 
        IO.puts(:stderr, "moduledoc for module '#{module}' not found, ignoring....")
      []
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
