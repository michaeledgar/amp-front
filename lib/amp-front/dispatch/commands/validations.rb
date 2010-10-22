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
#  © Michael J. Edgar and Ari Brown, 2009-2010                   #
#                                                                #
##################################################################

module Amp
  module Command
    module Validations
      def self.included(base)
        base.extend(ClassMethods)
      end
      module ClassMethods
        def before_blocks
          @before_blocks ||= []
        end
      
        def after_blocks
          @after_blocks ||= []
        end
      
        # Specifies one or more "before" callbacks that are run before
        # the command executes. If any of them return non-truthy, then
        # execution halts.
        #
        # @param block [Proc] a block to run
        def before(&block)
          before_blocks << block
        end
      
        # Specifies one or more "after" callbacks that are run before
        # the command executes. If any of them return non-truthy, then
        # execution halts.
        #
        # @param block [Proc] a block to run
        def after(&block)
          after_blocks << block
        end
      
        # Validates that the given block runs and returns true.
        # TODO(adgar): Document how :if, :unless work
        def validates_block(options={}, &block)
          before do |opts, args|
            if options[:if] || options[:unless]
              checker = options[:if] || options[:unless]
              result = if checker.is_a?(Proc)
                         checker.call(opts, args)
                       else
                         new.send(checker, opts, args)
                       end
              result = !result if options[:unless]
              next true unless result
            end
            block.call(opts, args)
          end
        end
      
        # Validates each the given options by running their values through the
        # block.
        def validates_each(*syms, &block)
          options = syms.last.is_a?(Hash) ? syms.pop : {}
          validates_block(options) do |opts, args|
            syms.all? {|sym| block.call(opts, sym, opts[sym])}
          end
        end
      
        # Validates that the given options were provided by the user.
        def validates_presence_of(*syms)
          validates_each(*syms) {|opts, attr, value| opts["#{attr}_given".to_sym]}
        end
      
        # Validates that the value of the given symbols is in the provided object.
        # Takes an options hash that must contain the :in key:
        #
        #    validates_inclusion_of :age, :favorite_number, :in => 13..18
        #
        # Also supports :if/:unless like the rails counterparts.
        def validates_inclusion_of(*syms)
          unless syms.last.is_a?(Hash)
            raise ArgumentError.new('validates_inclusion_of takes an options hash')
          end
          options = syms.last
          validates_each(*syms) {|opts, attr, value| options[:in].include?(value)}
        end
      
        VALID_LENGTH_KEYS = [:in, :within, :maximum, :minimum, :is]
        def extract_length_key(options)
          key_used = VALID_LENGTH_KEYS.find {|key| options.include?(key)}
          if key_used.nil?
            raise ArgumentError.new("One of #{VALID_LENGTH_KEYS.inspect} must be " +
                                    "provided to validates_length_of")
          end
          key_used
        end
      
        # Validates the length of the string provided as an argument matches the
        # provided constraints on length.
        #
        # @param [Symbol] attr the attribute to validate
        # @param [Hash] options A set of options that specifies the constraint.
        #   Must have one of the following: :in, :within, :maximum, :minimum, :is.
        def validates_length_of(attr, options={})
          key_used = extract_length_key options
          validates_block(options) do |opts, args|
            value = opts[attr].size
            numeric_comparison(value, key_used, options[key_used])
          end
        end
        alias_method :validates_size_of, :validates_length_of
      
        # Validates the number of arguments provided with the :in, :within, :maximum,
        # :minimum, and :is relationships. To validate that a user provided at least
        # 2 arguments in a copy command:
        #
        #    command "copy" do
        #      validates_argument_count :minimum => 2
        #    end
        #
        def validates_argument_count(options={})
          key_used = extract_length_key options
          validates_block(options) do |opts, args|
            value = args.size
            numeric_comparison(value, key_used, options[key_used])
          end
        end
      
        # Compares a value to a given constraint and returns whether it matches it
        # or not.
        #
        # @param [Integer] value a numeric value
        # @param [Symbol] key_used the key used for comparison. Either :within,
        #   :in, :maximum, :minimum, and :is.
        # @param [Integer, #include?] constraint a value to compare against
        # @return [Boolean]
        def numeric_comparison(value, key_used, constraint)
          if key_used == :in || key_used == :within
            constraint.include?(value)
          elsif key_used == :is
            constraint == value
          elsif key_used == :minimum
            constraint <= value
          elsif key_used == :maximum
            constraint >= value
          end
        end
      end

      # Is this a valid set of options and arguments for this command?
      def valid?(opts, args)
        self.class.before_blocks.all? {|block| block.call(opts, args)}
      end
      alias_method :run_before, :valid?
    
      def invalid?(opts, args)
        !valid?(opts, args)
      end

      def run_after(opts, args)
        self.class.after_blocks.all? {|block| block.call(opts, args)}
      end
    end
  end
end