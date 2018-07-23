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


module Console::Capture

	# MARK: - Printing

	def self.print(command : String, args = nil, *, env : Process::Env? = nil, clear_env : Bool = true , shell : Bool = false, prefix : String? = " > ", input = CLOSE, error : Bool = false) : Bool
		return capture_worker(command, args, env: env, clear_env: clear_env, shell: shell, input: input, error: error, chomp: false) { |line|
			Style.begin(Console.capture_style())
			Console << prefix if prefix
			Console << line
			Style.end()
		}
	end

	def self.style(string, prefix : String? = " > ") : Nil
		string.to_s.each_line(false) { |line|
			Style.begin(Console.capture_style())
			Console << prefix if prefix
			Console << line
			Style.end()
		}
	end

	# MARK: - Yielding

	def self.each(command : String, args = nil, *, env : Process::Env? = nil, clear_env : Bool = true, shell : Bool = false, input = CLOSE, error : Bool = false, delimiter : Char|String = '\n', chomp : Bool = true, &block : String -> Nil) : Bool
		return capture_worker(command, args, env: env, clear_env: clear_env, shell: shell, input: input, error: error, delimiter: delimiter, chomp: chomp) { |line| yield(line) }
	end


	# MARK: - String

	def self.string(command : String, args = nil, *, env : Process::Env? = nil, clear_env : Bool = true, shell : Bool = false, input = CLOSE, error : Bool = false) : { String?, Bool }
		string = nil
		success = capture_worker(command, args, env: env, clear_env: clear_env, shell: shell, input: input, error: error, delimiter: nil) { |value| string = value }
		return string, success
	end


	# MARK: - Utilities

	private def self.capture_worker(command : String, args, *, env : Process::Env?, clear_env : Bool, shell : Bool, input, error : Bool, delimiter : Char|String|Nil = '\n', chomp : Bool = true, &block : String -> Nil) : Bool
		success = false

		raise ArgumentError.new("Requires an input") if input.nil?

		if ( input.is_a?(String) )
			input = IO::Memory.new(input)
		elsif ( !input.is_a?(IO) )
			mem = IO::Memory.new()
			input.to_s(mem)
			input = mem
		end

		args = { args } if args.is_a?(String)

		IO.pipe() { |reader, writer|
			error = error ? writer : CLOSE
			spawn {
				success = Process.run(command, args, env: env, clear_env: clear_env, shell: shell, input: input, output: writer, error: writer).success?
				writer.close
			}

			if ( delimiter )
				while ( !reader.closed?  && ( line = reader.gets(delimiter, chomp) ) )
					yield(line)
				end
			else
				yield(reader.gets_to_end())
			end
		}

		return success
	end

end