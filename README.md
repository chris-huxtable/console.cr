# console.cr

Easy to use output control allowing redirection and buffering.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  console:
    github: chris-huxtable/console.cr
```


## Usage

```crystal
require "console"
```

### Printing to the Console:

```crystal
Console.print("This will print without a newline")
Console.line("This will print with a newline")
Console.line("This will", "print separate strings, with", "a newline", separator: ' ')
Console.words("This", "will", "print", "words", "or strings", "separated by single spaces", "and without a newline")

Console.print("All also feature", separator: "with different defaults", terminator: '.')
```

### Printing lists to the Console:

```crystal
Console.item("This is a list label")
#=> " - This is a list label\n"
Console.item("This is a list label", "with extras", justify: 30)
#=> " - This is a list label       with extras\n"

Console.item("This is a red list label", "with extras", justify: 30, style: Console::Style::Red)
#=> " - This is a red list label   with extras\n"

Console.status("This is a list label")
#=> " - This is a list label\n"
Console.status("This is a list label", "with a status", justify: 30)
#=> " - This is a list label       with a status\n"
Console.status("This is a red list label", "with a red status", justify: 30, style: Console::Style::Red)
#=> " - This is a list label       with a red status\n"
```

### Printing to a buffer:

```crystal
buffer = Console.buffer() {
	Console.line("This will be printed to the buffer")
	Console.line("Which will return a string")

	Console.repeat('=', 50)
	Console.newline()

	Console.line("You could then print it to the actual console if needed")
}

Console << buffer if something.went_wrong?
```


## Notes

- 'Monkey patches' `IO::Memory.truncate`
- Currently not `fork` or thread/fiber safe.


## Contributing

1. Fork it (<https://github.com/chris-huxtable/console.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Contributors

- [Chris Huxtable](https://github.com/chris-huxtable) - creator, maintainer
