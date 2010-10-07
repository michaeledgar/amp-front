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
    # Creates a new command class and sets its name appropriately. Yields
    # it, so it can be customized by the caller, adding options, an on_run
    # block, and so on.
    def self.create(name)
      @current_base_module ||= Amp::Command
      name = name.capitalize
      new_class = Class.new(Base)
      new_class.name = name
      yield new_class
      @current_base_module.const_set(name.to_s, new_class)
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
    
    # Looks up the command with the given name.
    def self.for_name(name)
      modules = name.split.map {|name| name.capitalize}
      current = Amp::Command
      modules.each do |module_name|
        if current.const_defined?(module_name)
          current = current.const_get(module_name)
        elsif current.is_a?(Class)
          return current
        else
          return nil
        end
      end
      return current
    end
  end
end