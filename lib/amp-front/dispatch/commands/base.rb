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
require File.expand_path(File.join(File.dirname(__FILE__), 'command.rb'))

module Amp
  module Command
    # The base class frmo which all comamnds inherit.
    class Base
      include Validations

      class << self
        attr_accessor :name, :options, :desc
      end

      # This tracks all subclasses (and subclasses of subclasses, etc). Plus, this
      # method is inherited, so Wool::Plugins::Git.all_subclasses will have all
      # subclasses of Wool::Plugins::Git!
      def self.all_commands
        @all_commands ||= [self]
      end

      # When a Plugin subclass is subclassed, store the subclass and inform the
      # next superclass up the inheritance hierarchy.
      def self.inherited(klass)
        self.all_commands << klass
        next_klass = self.superclass
        while next_klass != Amp::Command::Base.superclass
          next_klass.send(:inherited, klass)
          next_klass = next_klass.superclass
        end
      end

      # Specifies the block to run, or returns the block.
      def self.on_run(&block)
        @on_run = block if block_given?
        @on_run
      end
      
      def self.desc(*args)
        self.desc = args[0] if args.size == 1 && args[0].is_a?(String)
        @desc ||= ""
      end
      
      def self.options
        @options ||= []
      end
      
      def self.opt(*args)
        self.options << args
      end
      
      # Runs the command with the provided options and arguments.
      def run(options, arguments)
        self.class.on_run.call(options, arguments)
      end
      
      # Collects the options specific to this command and returns them.
      def collect_options
        base_options = self.class.options
        Trollop::options do
          base_options.each do |option|
            opt *option
          end
        end
      end
    end
  end
end

Dir[File.expand_path(File.dirname(__FILE__)) + '/base/**/*.rb'].each do |file|
  require file
end