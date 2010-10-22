##################################################################
#                  Licensing Information                         #
#                                                                #
#  The following code is licensed, as standalone code, under     #
#  the Ruby License, unless otherwise directed within the code.  #
#                                                                #
#  For information on the license of this code when distributed  #
#  with and used in conjunction with the other modules in the    #
#  Amp project, please see the root-level LICENSE file.          #
#                                                                #
##################################################################

module Amp::Dispatch
  class ArgumentOptions
    attr_reader :arguments
    attr_reader :options
    attr_reader :parser

    def initialize(args, opts = {}, par = nil)
      @arguments = args.freeze
      @options = opts.freeze
      @parser = par
      freeze
    end

    def parse(option_spec = nil, &block)
      args = @arguments.dup
      opts = {}
      if block
        par, opts = Trollop::options(args, &block)
      elsif option_spec
        par, opts = Trollop::options(args) do
          option_spec.each do |option|
            opt *option
          end
        end
      end
      self.class.new(args, opts.merge!(@options), par)
    end

    def trim_words(words)
      args = @arguments.dup
      words.each do |word|
        next_word = args.shift
        if next_word.downcase != word
          raise ArgumentError.new(
              "Failed to parse '#{words.inspect}'")
        end
      end
      self.class.new(args, @options)
    end
  end
end
