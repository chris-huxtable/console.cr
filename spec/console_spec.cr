require "./spec_helper"

macro console_eq(string, &block)
	buffer = Console.to_buffer() {
		{{yield()}}
	}
	buffer.should eq({{string}})
end


describe Console do

	it "buffers output" do
		console_eq("this is a test")	{ Console.print("this is a test") }
	end

	it "prints" do
		console_eq("this is a test")	{ Console.print("this is a test") }
		console_eq("thisisatest")		{ Console.print("this", "is", "a", "test") }
		console_eq("thisisatest")		{ Console.print("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test")	{ Console.print("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test")	{ Console.print("this", "is", "a", "test", separator: "-") }
		console_eq("this-is-a-test:")	{ Console.print("this", "is", "a", "test", separator: '-', terminator: ':') }
		console_eq("thisisatest:")		{ Console.print("this", "is", "a", "test", terminator: ':') }
	end

	it "prints line" do
		console_eq("this is a test\n")	{ Console.line("this is a test") }
		console_eq("thisisatest\n")		{ Console.line("this", "is", "a", "test") }
		console_eq("thisisatest\n")		{ Console.line("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test\n")	{ Console.line("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test\n")	{ Console.line("this", "is", "a", "test", separator: "-") }
		console_eq("this-is-a-test:")	{ Console.line("this", "is", "a", "test", separator: '-', terminator: ':') }
		console_eq("thisisatest:")		{ Console.line("this", "is", "a", "test", terminator: ':') }
	end

	it "prints words" do
		console_eq("this is a test")	{ Console.words("this is a test") }
		console_eq("this is a test")	{ Console.words("this", "is", "a", "test") }
		console_eq("thisisatest")		{ Console.words("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test")	{ Console.words("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test")	{ Console.words("this", "is", "a", "test", separator: "-") }
		console_eq("this-is-a-test:")	{ Console.words("this", "is", "a", "test", separator: '-', terminator: ':') }
		console_eq("this is a test:")	{ Console.words("this", "is", "a", "test", terminator: ':') }
	end

	it "prints repeats" do
		console_eq("aaaaa")		{ Console.repeat('a', 5) }
		console_eq("aaaaa")		{ Console.repeat("a", 5) }
		console_eq("ababab")	{ Console.repeat("ab", 3) }
		console_eq("ab")		{ Console.repeat("ab", 1) }
		console_eq("")			{ Console.repeat("ab", 0) }
	end

	it "prints newlines" do
		console_eq("\n")		{ Console.newline }
		console_eq("\n\n\n\n")	{ Console.newline(4) }
		console_eq("\n")		{ Console.newline(1) }
		console_eq("")			{ Console.newline(0) }
	end

	it "deletes" do
		console_eq("")			{ Console.print('a'); Console.delete }
		console_eq("a")			{ Console.print("ab"); Console.delete }
		console_eq("ac")		{ Console.print("ab"); Console.delete; Console.print("c"); }
		console_eq("")			{ Console.print("ab"); Console.delete(2) }
		console_eq("a")			{ Console.print("abc"); Console.delete(2) }
		console_eq("ac")		{ Console.print("abc"); Console.delete(2); Console.print("c"); }
	end

	it "appends" do
		console_eq("a")			{ Console << "a" }
		console_eq("ab")		{ Console << "a" << "b" }
	end

	it "stylizes with a single style" do
		style = Console::Style::Red

		console_eq("a")				{ Console.stylize("a", styles: style) }
		console_eq("a")				{ Console.stylize(style) { Console.print("a") } }
		Console.stylize = true
		console_eq("\e[31ma\e[0m")	{ Console.stylize("a", styles: style) }
		console_eq("\e[31ma\e[0m")	{ Console.stylize(style) { Console.print("a") } }
		Console.stylize = false
		console_eq("a")				{ Console.stylize("a", styles: style) }
		console_eq("a")				{ Console.stylize(style) { Console.print("a") } }
	ensure
		Console.stylize = nil
	end

	it "stylizes with multiple styles" do
		style = [Console::Style::Red, Console::Style::Underline]

		console_eq("a")					{ Console.stylize("a", styles: style) }
		console_eq("a")					{ Console.stylize(style) { Console.print("a") } }
		Console.stylize = true
		console_eq("\e[31;4ma\e[0m")	{ Console.stylize("a", styles: style) }
		console_eq("\e[31;4ma\e[0m")	{ Console.stylize(style) { Console.print("a") } }
		Console.stylize = false
		console_eq("a")					{ Console.stylize("a", styles: style) }
		console_eq("a")					{ Console.stylize(style) { Console.print("a") } }
	ensure
		Console.stylize = nil
	end

	it "prints a heading" do
		Console.stylize = false
		console_eq("this is a test:\n")		{ Console.heading("this is a test") }
		console_eq("this is a test:\n")		{ Console.heading("this", "is", "a", "test") }
		console_eq("thisisatest:\n")		{ Console.heading("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test:\n")		{ Console.heading("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test\n")		{ Console.heading("this", "is", "a", "test", separator: '-', terminator: nil) }
		console_eq("this is a test-\n")		{ Console.heading("this", "is", "a", "test", terminator: '-') }
		console_eq("Heading:\nbody\n\n")	{ Console.heading("Heading") { Console.line("body") } }

		Console.stylize = true
		console_eq("\e[4;1mthis is a test:\e[0m\n")		{ Console.heading("this is a test") }
		console_eq("\e[4;1mHeading:\e[0m\nbody\n\n")	{ Console.heading("Heading") { Console.line("body") } }
	ensure
		Console.stylize = nil
	end

	it "prints a sub heading" do
		Console.stylize = false
		console_eq("this is a test:\n")		{ Console.sub_heading("this is a test") }
		console_eq("this is a test:\n")		{ Console.sub_heading("this", "is", "a", "test") }
		console_eq("thisisatest:\n")		{ Console.sub_heading("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test:\n")		{ Console.sub_heading("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test\n")		{ Console.sub_heading("this", "is", "a", "test", separator: '-', terminator: nil) }
		console_eq("this is a test-\n")		{ Console.sub_heading("this", "is", "a", "test", terminator: '-') }

		console_eq("Sub Heading:\nbody\n")	{ Console.sub_heading("Sub Heading") { Console.line("body") } }

		Console.stylize = true
		console_eq("this is a test:\n")		{ Console.sub_heading("this is a test") }
		console_eq("Heading:\nbody\n")		{ Console.sub_heading("Heading") { Console.line("body") } }
	ensure
		Console.stylize = nil
	end

	it "prints items" do
		style = [Console::Style::Red, Console::Style::Underline]

		Console.stylize = false
		console_eq(" - test label\n")					{ Console.item("test label") }
		console_eq(" - test label       correct\n")		{ Console.item("test label", "correct", 20) }
		console_eq(" - test label-------correct\n")		{ Console.item("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      correct\n")		{ Console.item("test label", "correct", 20, symbol: ">>") }
		console_eq(" - test label       correct\n")		{ Console.status("test label", "correct", 20) }
		console_eq(" - test label       correct\n")		{ Console.status("test label", "correct", 20, style: style) }
		console_eq(" - test label-------correct\n")		{ Console.status("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      correct\n")		{ Console.status("test label", "correct", 20, symbol: ">>") }

		Console.stylize = true
		console_eq(" - test label\n")								{ Console.item("test label") }
		console_eq("\e[31;4m - test label\e[0m       correct\n")	{ Console.item("test label", "correct", 20, style: style) }
		console_eq(" - test label-------correct\n")					{ Console.item("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      correct\n")					{ Console.item("test label", "correct", 20, symbol: ">>") }
		console_eq(" - test label       correct\n")					{ Console.status("test label", "correct", 20) }
		console_eq(" - test label       \e[31;4mcorrect\e[0m\n")	{ Console.status("test label", "correct", 20, style: style) }
		console_eq(" - test label-------correct\n")					{ Console.status("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      correct\n")					{ Console.status("test label", "correct", 20, symbol: ">>") }
	ensure
		Console.stylize = nil
	end

	it "affirms" do
		Console.stylize = false
		console_eq("this is a test")	{ Console::Affirm.print("this is a test") }
		console_eq("thisisatest")		{ Console::Affirm.print("this", "is", "a", "test") }
		console_eq("thisisatest")		{ Console::Affirm.print("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test")	{ Console::Affirm.print("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test:")	{ Console::Affirm.print("this", "is", "a", "test", separator: '-', terminator: ':') }
		console_eq("thisisatest:")		{ Console::Affirm.print("this", "is", "a", "test", terminator: ':') }

		console_eq(" + test label\n")					{ Console::Affirm.item("test label") }
		console_eq(" + test label       correct\n")		{ Console::Affirm.item("test label", "correct", 20) }
		console_eq(" + test label-------correct\n")		{ Console::Affirm.item("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      correct\n")		{ Console::Affirm.item("test label", "correct", 20, symbol: ">>") }
		console_eq(" - test label       correct\n")		{ Console::Affirm.status("test label", "correct", 20) }
		console_eq(" - test label-------correct\n")		{ Console::Affirm.status("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      correct\n")		{ Console::Affirm.status("test label", "correct", 20, symbol: ">>") }

		Console.stylize = true
		console_eq("\e[32mthis is a test\e[0m")		{ Console::Affirm.print("this is a test") }
		console_eq("\e[32;4mthis is a test\e[0m")	{ Console::Affirm.strongly("this is a test") }

		console_eq("\e[32m + test label\e[0m\n")					{ Console::Affirm.item("test label") }
		console_eq("\e[32m + test label\e[0m       correct\n")		{ Console::Affirm.item("test label", "correct", 20) }
		console_eq("\e[32m + test label\e[0m-------correct\n")		{ Console::Affirm.item("test label", "correct", 20, separator: '-') }
		console_eq("\e[32m >> test label\e[0m      correct\n")		{ Console::Affirm.item("test label", "correct", 20, symbol: ">>") }
		console_eq(" - test label       \e[32mcorrect\e[0m\n")		{ Console::Affirm.status("test label", "correct", 20) }
		console_eq(" - test label-------\e[32mcorrect\e[0m\n")		{ Console::Affirm.status("test label", "correct", 20, separator: '-') }
		console_eq(" >> test label      \e[32mcorrect\e[0m\n")		{ Console::Affirm.status("test label", "correct", 20, symbol: ">>") }
	ensure
		Console.stylize = nil
	end

	it "warns" do
		Console.stylize = false
		console_eq("this is a test")	{ Console::Warn.print("this is a test") }
		console_eq("thisisatest")		{ Console::Warn.print("this", "is", "a", "test") }
		console_eq("thisisatest")		{ Console::Warn.print("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test")	{ Console::Warn.print("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test:")	{ Console::Warn.print("this", "is", "a", "test", separator: '-', terminator: ':') }
		console_eq("thisisatest:")		{ Console::Warn.print("this", "is", "a", "test", terminator: ':') }

		console_eq(" ~ test label\n")					{ Console::Warn.item("test label") }
		console_eq(" ~ test label       warning\n")		{ Console::Warn.item("test label", "warning", 20) }
		console_eq(" ~ test label-------warning\n")		{ Console::Warn.item("test label", "warning", 20, separator: '-') }
		console_eq(" >> test label      warning\n")		{ Console::Warn.item("test label", "warning", 20, symbol: ">>") }
		console_eq(" - test label       warning\n")		{ Console::Warn.status("test label", "warning", 20) }
		console_eq(" - test label-------warning\n")		{ Console::Warn.status("test label", "warning", 20, separator: '-') }
		console_eq(" >> test label      warning\n")		{ Console::Warn.status("test label", "warning", 20, symbol: ">>") }

		Console.stylize = true
		console_eq("\e[33mthis is a test\e[0m")		{ Console::Warn.print("this is a test") }
		console_eq("\e[33;4mthis is a test\e[0m")	{ Console::Warn.strongly("this is a test") }

		console_eq("\e[33m ~ test label\e[0m\n")					{ Console::Warn.item("test label") }
		console_eq("\e[33m ~ test label\e[0m       warning\n")		{ Console::Warn.item("test label", "warning", 20) }
		console_eq("\e[33m ~ test label\e[0m-------warning\n")		{ Console::Warn.item("test label", "warning", 20, separator: '-') }
		console_eq("\e[33m >> test label\e[0m      warning\n")		{ Console::Warn.item("test label", "warning", 20, symbol: ">>") }
		console_eq(" - test label       \e[33mwarning\e[0m\n")		{ Console::Warn.status("test label", "warning", 20) }
		console_eq(" - test label-------\e[33mwarning\e[0m\n")		{ Console::Warn.status("test label", "warning", 20, separator: '-') }
		console_eq(" >> test label      \e[33mwarning\e[0m\n")		{ Console::Warn.status("test label", "warning", 20, symbol: ">>") }
	ensure
		Console.stylize = nil
	end

	it "errors" do
		Console.stylize = false
		console_eq("this is a test")	{ Console::Error.print("this is a test") }
		console_eq("thisisatest")		{ Console::Error.print("this", "is", "a", "test") }
		console_eq("thisisatest")		{ Console::Error.print("this", "is", "a", "test", separator: nil) }
		console_eq("this-is-a-test")	{ Console::Error.print("this", "is", "a", "test", separator: '-') }
		console_eq("this-is-a-test:")	{ Console::Error.print("this", "is", "a", "test", separator: '-', terminator: ':') }
		console_eq("thisisatest:")		{ Console::Error.print("this", "is", "a", "test", terminator: ':') }

		console_eq(" x test label\n")					{ Console::Error.item("test label") }
		console_eq(" x test label       error\n")		{ Console::Error.item("test label", "error", 20) }
		console_eq(" x test label-------error\n")		{ Console::Error.item("test label", "error", 20, separator: '-') }
		console_eq(" >> test label      error\n")		{ Console::Error.item("test label", "error", 20, symbol: ">>") }
		console_eq(" - test label       error\n")		{ Console::Error.status("test label", "error", 20) }
		console_eq(" - test label-------error\n")		{ Console::Error.status("test label", "error", 20, separator: '-') }
		console_eq(" >> test label      error\n")		{ Console::Error.status("test label", "error", 20, symbol: ">>") }

		Console.stylize = true
		console_eq("\e[31mthis is a test\e[0m")		{ Console::Error.print("this is a test") }
		console_eq("\e[31;4mthis is a test\e[0m")	{ Console::Error.strongly("this is a test") }

		console_eq("\e[31m x test label\e[0m\n")					{ Console::Error.item("test label") }
		console_eq("\e[31m x test label\e[0m       error\n")		{ Console::Error.item("test label", "error", 20) }
		console_eq("\e[31m x test label\e[0m-------error\n")		{ Console::Error.item("test label", "error", 20, separator: '-') }
		console_eq("\e[31m >> test label\e[0m      error\n")		{ Console::Error.item("test label", "error", 20, symbol: ">>") }
		console_eq(" - test label       \e[31merror\e[0m\n")		{ Console::Error.status("test label", "error", 20) }
		console_eq(" - test label-------\e[31merror\e[0m\n")		{ Console::Error.status("test label", "error", 20, separator: '-') }
		console_eq(" >> test label      \e[31merror\e[0m\n")		{ Console::Error.status("test label", "error", 20, symbol: ">>") }
	ensure
		Console.stylize = nil
	end

	it "silence-able" do
		console_eq("this is a test")	{ Console.print("this is a test") }
		Console.silenced() {
			console_eq("") { Console.print("this is a test") }
		}
	end

	it "captures" do
		console_eq(" > this is a test\n")				{ Console::Capture.print("echo", {"this is a test"}, shell: true) }
		Console.stylize = true
		console_eq("\e[37m > this is a test\n\e[0m")	{ Console::Capture.print("echo", {"this is a test"}, shell: true) }
	ensure
		Console.stylize = nil
	end

	it "captures each" do
		line0 = nil
		line1 = nil
		Console::Capture.each("echo", {"this is\n a test"}, shell: true) { |line|
			next line0 = line if line0.nil?
			next line1 = line if line1.nil?
		}
		line0.should eq("this is")
		line1.should eq(" a test")
	end

	it "captures to string" do
		string, success = Console::Capture.string("echo", {"this is a test"}, shell: true)
		success.should be_true
		string.should eq("this is a test\n")
	end

	it "prints styled" do
		console_eq(" > this is\n > a test")	{ Console::Capture.style("this is\na test") }
	end

end
