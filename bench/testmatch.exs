
r = ~r/\A(.*?)\n(.*)\z/ms
a = fn s ->
  [_, l, r ] = Regex.run(r, s)
  {l, r}
end

# f = File.read!("README.xxx")
f = ~S"""
Hello
World
Again

"""
s = (1..String.to_integer(System.argv |> List.first || "10"))
# s = (1..10)
    |> Enum.map(fn _ -> f end) 
    |> Enum.join

IO.puts(String.length(s) / 1000)

(1..10)
|> Enum.reduce(s, fn _, r ->
  {l, r} = a.(r)
  IO.puts(l)
  r
end)
 
