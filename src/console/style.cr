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


enum Console::Style : UInt8

	Black		= 30
	Red			= 31
	Green		= 32
	Yellow		= 33
	Blue		= 34
	Magenta		= 35
	Cyan		= 36
	Grey		= 37
	White		= 37
	Bold		= 1
	Intense		= 1
	Itaic		= 3
	Faint		= 3
	Underline	= 4
	Blink		= 5

	def to_s(io : IO)
		io << value
	end


	# MARK: - Class Methds

	def self.print(*strings, styles : StyleTypes?, separator = nil, terminator = nil) : Style.class
		return Style if ( Console.silenced? || strings.empty? || !styles )
		print(styles) { Console.internal_print(*strings, separator: separator, terminator: terminator) }

		return Style
	end

	def self.print(styles : Enumerable(Style), &block : -> Nil) : Style.class
		if ( styles.empty? || !Console.stylize? )
			yield()
			return Style
		end

		Style.begin(styles)
		yield()
		Style.end()

		return Style
	end

	def self.print(style : Style?, &block : -> Nil) : Style.class
		Style.begin(style)
		yield()
		Style.end() if ( style )

		return Style
	end

	def self.begin(style : Style?) : Style.class
		return Style if ( !style || Console.silenced? || !Console.stylize? )

		Console << "\e["
		Console << style
		Console << 'm'

		return Style
	end

	def self.begin(styles : Enumerable(Style)) : Style.class
		return Style if ( Console.silenced? || !Console.stylize? )

		Console.print("\e[")

		styles.each_with_index() do |elem, i|
			Console << ';' if i > 0
			Console << elem
		end
		Console << 'm'

		return Style
	end

	def self.end() : Style.class
		return Style if ( Console.silenced? || !Console.stylize? )
		Console.print("\e[0m")
		return Style
	end

end
