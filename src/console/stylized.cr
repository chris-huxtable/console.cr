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

			protected def self.internal_print(*strings, separator = nil, terminator = nil, style : StyleTypes = DEFAULT) : Console.class
				return Console.stylize(style) {
					Console.internal_print(*strings, separator: separator, terminator: terminator)
				}
			end

			def self.print(*strings, separator = nil, terminator = nil) : Console.class
				return Console if ( Console.silenced? )
				return internal_print(*strings, separator: separator, terminator: terminator)
			end

			def self.strongly(*strings, separator = nil, terminator = nil) : Console.class
				return Console if ( Console.silenced? )
				return internal_print(*strings, separator: separator, terminator: terminator, style: STRONG)
			end

			def self.line(*strings, separator = nil, terminator = '\n') : Console.class
				return Console if ( Console.silenced? )
				return internal_print(*strings, separator: separator, terminator: terminator)
			end

			def self.words(*strings, separator = ' ', terminator = nil) : Console.class
				return Console if ( Console.silenced? )
				return internal_print(*strings, separator: separator, terminator: terminator)
			end

			def self.repeat(string, count : Int = 1, strong : Bool = false) : Console.class
				return Console if ( Console.silenced? || count <= 0 )
				return Console.stylize(strong ? STRONG : DEFAULT) {
					count.times() { Console << string }
				}
			end

			protected def self.internal_item(label, extra, *, symbol, separator : Char, strong : Bool, justify : Int) : Console.class
				return Console if ( Console.silenced? )

				label = label.to_s if ( extra )

				Console.stylize(strong ? STRONG : DEFAULT) {
					Console.print(' ', symbol, ' ')
					Console.print(label)
				}
				return Console.newline if !extra

				Console.offset(label, symbol, separator, justify) if ( justify > 0 )

				Console.print(extra) if ( extra )
				return Console.newline
			end

			def self.status(label, status, *, separator : Char = ' ', symbol = '-', strong : Bool = false, justify : Int = 0) : Console.class
				return Console if ( Console.silenced? )

				label = label.to_s
				Console.print(' ', symbol, ' ')
				Console.print(label)

				Console.offset(label, symbol, separator, justify) if ( justify > 0 )

				Console.stylize(strong ? STRONG : DEFAULT) {
					Console.print(status)
				}
				return Console.newline
			end

		end

	end

end

module Console::Affirm
	DEFAULT	= Style::Green
	STRONG	= [Style::Green, Style::Underline]

	extend StyleMixin

	def self.item(label, extra = nil, *, symbol = '+', separator : Char = ' ', strong : Bool = false, justify : Int = 0) : Console.class
		return internal_item(label, extra, symbol: symbol, separator: separator, strong: strong, justify: justify)
	end
end


module Console::Warn
	DEFAULT	= Style::Yellow
	STRONG	= [Style::Yellow, Style::Underline]

	extend StyleMixin

	def self.item(label, extra = nil, *, symbol = '~', separator : Char = ' ', strong : Bool = false, justify : Int = 0) : Console.class
		return internal_item(label, extra, symbol: symbol, separator: separator, strong: strong, justify: justify)
	end
end


module Console::Error
	DEFAULT	= Style::Red
	STRONG	= [Style::Red, Style::Underline]

	extend StyleMixin

	def self.item(label, extra = nil, *, symbol = 'x', separator = ' ', strong : Bool = false, justify : Int = 0) : Console.class
		return internal_item(label, extra, symbol: symbol, separator: separator, strong: strong, justify: justify)
	end
end
