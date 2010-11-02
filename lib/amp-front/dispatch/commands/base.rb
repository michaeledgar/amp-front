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
require File.expand_path(File.join(File.dirname(__FILE__), 'validations.rb'))

module Amp
  module Command
    # Creates a new command class and sets its name appropriately. Yields
    # it, so it can be customized by the caller, adding options, an on_call
    # block, and so on.
    def self.create(name)
      @current_base_module ||= Amp::Command
      name = name.capitalize
      new_class = Class.new(Base)
      new_class.name = name
      yield new_class
      @current_base_module.const_set(name, new_class)
      Amp::Help::CommandHelpEntry.new(name.downcase, new_class)
      new_class
    end
    
    # Runs the provided block with a base module of the given name. So
    # instead of creating Amp::Command::NewCommand, this allows you to
    # namespace created code as Amp::Command::MyModule::NewCommand, isolating
    # it from other plugins.
    def self.namespace(namespace)
      old_namespace = @current_base_module ||= Amp::Command
      namespace = namespace.capitalize

      unless old_namespace.const_defined?(namespace)
        new_namespace = Module.new
        old_namespace.const_set(namespace, new_namespace)
      end
      @current_base_module = const_get(namespace)
      yield
    ensure
      @current_base_module = old_namespace
    end
    
    # See if the specified module list matches a defined constant
    def self.lookup_const(modules)
      current = Amp::Command
      modules.each do |module_name|
        if module_name =~ /^[A-Za-z0-9_]+$/ && current.const_defined?(module_name)
          current = current.const_get(module_name)
        else
          return current
        end
      end
      return current
    end

    # return the argument if 'new' would succeed
    def self.creatable(command)
      command.is_a?(Class) ? command : nil
    end
    
    # Looks up the command with the given name.
    def self.for_name(name)
      modules = name.split.map {|name| name.capitalize}
      creatable(lookup_const(modules))
    end
    
    # The base class frmo which all comamnds inherit.
    class Base
      include Validations

      # --------------- class part ----------------

      class << self
        attr_accessor :name, :options, :desc
      end
      self.name = 'Base'
      
      # This tracks all subclasses (and subclasses of subclasses, etc). Plus, this
      # method is inherited, so Wool::Plugins::Git.all_subclasses will have all
      # subclasses of Wool::Plugins::Git!
      def self.all_commands
        @all_commands ||= [self]
      end

      # When a Plugin subclass is subclassed, store the subclass and inform the
      # next superclass up the inheritance hierarchy.
      def self.inherited(klass)
        klass.name ||= 'anonymous ' + self.name
        self.all_commands << klass
        next_klass = self.superclass
        while next_klass != Amp::Command::Base.superclass
          next_klass.send(:inherited, klass)
          next_klass = next_klass.superclass
        end
      end

      # Specifies the block to run, or returns the block.
      def self.on_call(&block)
        @on_call = block if block_given?
        @on_call
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

      # Return the class name as the array of words used to run it
      #  Help => [help]
      #  Git::Rebase => [git rebase]
      def self.path_parts
        inspect.gsub(/Amp::Command::/, '').gsub(/::/, ' ').split.map(&:downcase)
      end
      
      # --------------- instance part ----------------

      # These are the runtime options selected when the command is called.
      attr_accessor :options, :arguments

      # Runs the command with the provided options and arguments.
      def call(options, arguments)
        self.options = options
        self.arguments = arguments
        instance_eval(&self.class.on_call)
      end
      
      # Collects the options specific to this command and returns them.
      def collect_options(arguments)
        args = arguments.parse(self.class.options)
        @parser ||= args.parser
        args
      end
      
      def education
        if @parser
          output = StringIO.new
          @parser.educate(output)
          output.string
        else
          ''
        end
      end
    end
  end
end

Dir[File.expand_path(File.dirname(__FILE__)) + '/builtin/**/*.rb'].each do |file|
  require file
end