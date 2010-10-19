# Amp Frontend Plugin Design Doc

This document intends to specify how plugins will be managed by the generic
Amp front-end.

## Amp::Plugin Subclasses

By tracking the subclasses (and subclasses of subclasses) of Amp::Plugin, we
can look up all plugins that are loaded. Thus, to register a plugin, one simply
needs to load a Ruby file that contains the definition of an Amp::Plugin subclass.

The list of all plugins can be retrieved with the following Ruby code:

    Amp::Plugin.all_plugins

Which is simply an accessor to an ivar on the Amp::Plugin metaclass. Following
the Ruby convention of preferring convention over configuration, the default
Ampfile contains the following, single statement:

    Amp::Plugin.load_rubygems_plugins

which, when run, all gems are searched for the file 'amp/plugin.rb'. All such files
are loaded in an arbitrary order.

If a plugin is automatically loaded that you *do not* wish to be loaded, you
will have to require each one individually. You do not need to manually load
amp-core. amp-core will be loaded first.

## Plugin Callbacks

Each plugin class in `Amp::Plugin.all_plugins` is instantiated with the current
global configuration as the sole parameter:

    class Amp::Plugin::Git < Amp::Plugin::Base
      def initialize(settings)
        puts "oh noez" if settings[:failboatz]
      end
    end
    
Or the simpler:

    amp_plugin 'git' do
      init do |settings|
        puts "oh noez" if settings[:failboatz]
      end
    end

