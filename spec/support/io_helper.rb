require 'inquirer'

# overload all necessary methods of iohelper
# this will serve as a mock helper to read input and output
module IOHelper
  extend self
  attr_accessor :output, :keys
  def render(sth)
    @output += sth
  end

  def clear
    @output = ''
  end

  def rerender(sth)
    @output = sth
  end

  def read_key_while(_return_char = false, &block)
    chop_index = nil
    Array(@keys).each_with_index do |key, index|
      chop_index = index
      break unless block.call(key)
    end

    @keys.slice!(0, chop_index + 1) if chop_index
  end

  def type_input(input)
    @keys ||= []
    input.each_char { |c| @keys << c }
    @keys << "\r"
  end

  def confirm
    @keys << 'y'
  end
end
