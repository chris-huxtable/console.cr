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


module Console

	HEADING_STYLE		= [Style::Underline, Style::Bold]
	SUB_HEADING_STYLE	= [] of Style


	# MARK: - Special Styles

	def self.heading(*strings, separator = ' ', terminator = ':') : Console.class
		stylize(*strings, separator: separator, terminator: terminator, styles: HEADING_STYLE)
		newline()

		return Console
	end

	def self.heading(*strings, separator = ' ', terminator = ':', &block : -> _)
		heading(*strings, separator: separator, terminator: terminator)
		passthrough = yield()
		newline()

		return passthrough
	end

	def self.sub_heading(*strings, separator = ' ', terminator = ':') : Console.class
		stylize(*strings, separator: separator, terminator: terminator, styles: SUB_HEADING_STYLE)
		newline()
	end

	def self.sub_heading(*strings, separator = ' ', terminator = ':', &block : -> _)
		sub_heading(*strings, separator: separator, terminator: terminator)
		return yield()
	end


	private module StyleMixin

		macro extended

			protected def self.styling(*, strong : Bool = false) : StyleTypes
				return strong ? STRONG : DEFAULT
			end

			protected def self.internal_print(*strings, separator = nil, terminator = nil, style : StyleTypes = styling()) : Console.class
				return Console.stylize(style) {
					Console.internal_print(*strings, separator: separator, terminator: terminator)
				}
			end

		end

		def print(*strings, separator = nil, terminator = nil) : Console.class
			return Console if ( Console.silenced? )
			return internal_print(*strings, separator: separator, terminator: terminator)
		end

		def strongly(*strings, separator = nil, terminator = nil) : Console.class
			return Console if ( Console.silenced? )
			return internal_print(*strings, separator: separator, terminator: terminator, style: styling(strong: true))
		end

		def line(*strings, separator = nil, terminator = '\n') : Console.class
			return Console if ( Console.silenced? )
			return internal_print(*strings, separator: separator, terminator: terminator)
		end

		def words(*strings, separator = ' ', terminator = nil) : Console.class
			return Console if ( Console.silenced? )
			return internal_print(*strings, separator: separator, terminator: terminator)
		end

		def repeat(string, count : Int = 1, strong : Bool = false) : Console.class
			return Console if ( Console.silenced? || count <= 0 )
			return Console.stylize(styling(strong: strong)) {
				count.times() { Console << string }
			}
		end

		def status(label, status, justify : Int = 0, *, separator : Char = ' ', symbol = '-', strong : Bool = false) : Console.class
			return Console.status(label, status, justify, symbol: symbol, separator: separator, style: styling(strong: strong))
		end

	end

end

module Console::Affirm
	DEFAULT	= Style::Green
	STRONG	= [Style::Green, Style::Underline]

	extend StyleMixin

	def self.item(label, extra = nil, justify : Int = 0, *, symbol = '+', separator : Char = ' ', strong : Bool = false) : Console.class
		return Console.item(label, extra, justify, symbol: symbol, separator: separator, style: styling(strong: strong))
	end
end


module Console::Warn
	DEFAULT	= Style::Yellow
	STRONG	= [Style::Yellow, Style::Underline]

	extend StyleMixin

	def self.item(label, extra = nil, justify : Int = 0, *, symbol = '~', separator : Char = ' ', strong : Bool = false) : Console.class
		return Console.item(label, extra, justify, symbol: symbol, separator: separator, style: styling(strong: strong))
	end
end


module Console::Error
	DEFAULT	= Style::Red
	STRONG	= [Style::Red, Style::Underline]

	extend StyleMixin

	def self.item(label, extra = nil, justify : Int = 0, *, symbol = 'x', separator = ' ', strong : Bool = false) : Console.class
		return Console.item(label, extra, justify, symbol: symbol, separator: separator, style: styling(strong: strong))
	end

	def self.fatal(*strings, code : Int = 1, separator = " ", terminator = "\n") : Nil
		strongly(*strings, separator: separator, terminator: terminator)
		exit(code)
	end

end
