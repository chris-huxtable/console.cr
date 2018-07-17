# Copyright (c) 2018 Christian Huxtable <chris@huxtable.ca>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require "./io/memory"


module Console

	private PIPE		= Process::Redirect::Pipe
	private CLOSE		= Process::Redirect::Close

	CAPTURE_STYLE		= Style::White

	alias StyleTypes	= Style|Enumerable(Style)


	@@silence = 0
	@@stylize = nil
	@@output : IO = STDOUT

	@@capture_style = CAPTURE_STYLE


	# MARK: - Properties

	def self.tty? : Bool
		return @@output.tty?
	end

	def self.stylize=(value : Bool?) : Nil
		@@stylize = value
	end

	def self.stylize?() : Bool
		retval = @@stylize
		return retval if ( !retval.nil? )
		return tty?
	end

	class_property capture_style : StyleTypes


	# MARK: - Control Commands

	def self.flush()
		@@output.flush
	end


	# MARK: - Output

	def self.output=(output : IO) : Nil
		flush()
		@@output = output
	end

	def self.output(output : IO, &block) : Nil
		tmp = @@output
		begin
			flush()
			@@output = output
			yield()
		ensure
			flush()
			@@output = tmp
		end
	end


	# MARK: - Special

	# FIXME: - Not fork safe.
	def self.to_buffer(&block : -> Nil) : String
		buffer = IO::Memory.new()
		output(buffer) { yield() }
		return buffer.to_s
	end

	def self.to_error(&block : -> Nil) : Nil
		output(STDERR) { yield() }
	end


	# MARK: - Writing

	protected def self.internal_print(*strings, separator = nil, terminator = nil) : Console.class
		strings.join(separator, @@output)
		terminator.to_s(@@output) if ( !terminator.nil? )

		return Console
	end

	def self.print(*strings, separator = nil, terminator = nil) : Console.class
		return Console if ( silenced? )
		return internal_print(*strings, separator: separator, terminator: terminator)
	end

	def self.line(*strings, separator = nil, terminator = '\n') : Console.class
		return Console if ( silenced? )
		return internal_print(*strings, separator: separator, terminator: terminator)
	end

	def self.words(*strings, separator = ' ', terminator = nil) : Console.class
		return Console if ( silenced? )
		return internal_print(*strings, separator: separator, terminator: terminator)
	end

	def self.repeat(string, count : Int = 1) : Console.class
		return Console if ( silenced? || count <= 0 )
		count.times() { @@output << string }
		return Console
	end

	def self.newline(count : Int = 1) : Console.class
		return repeat('\n', count)
	end

	def self.delete(count : Int = 1) : Console.class
		return Console if ( silenced? )

		return repeat("\b \b", count) if ( tty?() )

		output = @@output
		raise "Output type unsupported" if ( !output.is_a?(IO::Memory) )

		output.seek(-count, IO::Seek::Current)
		output.truncate()

		return Console
	end

	def self.<<(string) : Console.class
		string.to_s(@@output)
		return Console
	end

	def self.stylize(styles : StyleTypes?, &block : -> Nil) : Console.class
		Style.print(styles) { yield() }
		return Console
	end

	def self.stylize(*strings, styles : StyleTypes?, separator = nil, terminator = nil) : Console.class
		Style.print(*strings, styles: styles, separator: separator, terminator: terminator)
		return Console
	end


	# MARK: - Listing

	def self.item(label, extra = nil, justify : Int = 0, *, symbol = '-', separator : Char = ' ', style : StyleTypes? = nil) : Console.class
		return Console if ( Console.silenced? )

		label = label.to_s if ( extra )

		Console.stylize(style) {
			Console.print(' ', symbol, ' ')
			Console.print(label)
		}
		return Console.newline if !extra

		Console.offset(label, symbol, separator, justify) if ( justify > 0 )

		Console.print(extra) if ( extra )
		return Console.newline
	end

	def self.status(label, status, justify : Int = 0, *, separator : Char = ' ', symbol = '-', style : StyleTypes? = nil) : Console.class
		return Console if ( Console.silenced? )

		label = label.to_s
		Console.print(' ', symbol, ' ')
		Console.print(label)

		Console.offset(label, symbol, separator, justify) if ( justify > 0 )

		Console.stylize(style) {
			Console.print(status)
		}
		return Console.newline
	end


	# MARK: - Commands

	def self.capture(command : String, env : Process::Env? = nil, clear_env : Bool = false, shell : Bool = false, prefix : String? = " > ", input = CLOSE, error : Bool = false) : Bool
		return capture_worker(command, nil, env: env, clear_env: clear_env, shell: shell, prefix: prefix, input: input, error: error)
	end

	def self.capture(command : String, *args : String, env : Process::Env? = nil, clear_env : Bool = false, shell : Bool = false, prefix : String? = " > ", input = CLOSE, error : Bool = false) : Bool
		return capture_worker(command, args, env: env, clear_env: clear_env, shell: shell, prefix: prefix, input: input, error: error)
	end

	private def self.capture_worker(command : String, args, env : Process::Env?, clear_env : Bool, shell : Bool, prefix, input, error : Bool) : Bool
		success = false
		IO.pipe() { |reader, writer|
			error = error ? writer : CLOSE
			spawn {
				success = Process.run(command, args, env: env, clear_env: clear_env, shell: shell, input: input, output: writer, error: writer).success?
				writer.close
			}

			while ( !reader.closed?  && ( line = reader.gets ) )
				Style.begin(capture_style())
				Console << prefix if prefix
				Console << line << '\n'
				Style.end()
			end
		}

		return success
	end


	# MARK: - Silence

	def self.silence() : Console.class
		@@silence += 1
		return Console
	end

	def self.unsilence() : Console.class
		@@silence -= 1 if ( silenced?() )
		return Console
	end

	def self.silenced?() : Bool
		return ( @@silence > 0 )
	end

	def self.silenced(&block : -> Nil) : Console.class
		silence()
		yield()
		return self
	ensure
		unsilence()
	end


	# MARK: - Utilities

	protected def self.offset(label, symbol, separator : Char, justify : Int) : Nil
		offset = 2 + label.size

		offset += case symbol
			when Char	then 1
			when String	then symbol.to_s
			else symbol.to_s.size
		end

		Console.repeat(separator, justify - offset) if offset < justify
	end

end

require "./console/*"
