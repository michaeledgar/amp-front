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
  module Plugins
    class Base
      extend ModuleExtensions
      cattr_accessor :module, :author
      cattr_accessor_with_default :loaded_plugins, []

      # This tracks all subclasses (and subclasses of subclasses, etc). Plus, this
      # method is inherited, so Wool::Plugins::Git.all_subclasses will have all
      # subclasses of Wool::Plugins::Git!
      def self.all_plugins
        @all_plugins ||= [self]
      end

      # When a Plugin subclass is subclassed, store the subclass and inform the
      # next superclass up the inheritance hierarchy.
      def self.inherited(klass)
        self.all_plugins << klass
        next_klass = self.superclass
        while next_klass != Amp::Plugins::Base.superclass
          next_klass.send(:inherited, klass)
          next_klass = next_klass.superclass
        end
      end
      
      # Creates a Plugin subclass with the given name. Also allows specifying
      # the superclass to use.
      #
      # Reopens existing plugins if they already exist, for user customization.
      def self.create(name, superclass=Amp::Plugins::Base)
        unless (name = name.to_s) && name.size > 0
          raise ArgumentError.new('name must be a non-empty string')
        end
        name = name[0,1].upcase + name[1..-1]
        klass = nil
        Amp::Plugins.class_eval do
          if const_defined?(name)
            klass = const_get(name)
          else
            klass = Class.new(superclass)
            const_set(name, klass)  # So the class has a name
          end
          yield klass if block_given?
        end
        klass
      end
      
      def self.load_rubygems_plugins
        require 'rubygems'
        files = Gem.find_files('amp_plugin.rb')
        files.each do |file|
          load file
        end
      end
      
      # Generic initialization all plugins perform. Takes an options hash.
      def initialize(opts={})
      end
      
      def inspect
        "#<Amp::Plugin::#{self.module} #{self.class.name} by #{self.class.author}>"
      end
      
      def module
        self.class.module || self.class.name
      end
      
      def load!
        # Subclasses should implement this.
      end
    end
  end
end