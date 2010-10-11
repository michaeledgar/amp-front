module Amp
  VERSION = '0.0.1'
  VERSION_TITLE = 'Koyaanisqatsi'

  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

  module Dispatch
    autoload :Runner, 'amp-front/dispatch/runner.rb'
  end

  module Help
    autoload :HelpUI,           'amp-front/help/help.rb'
    autoload :HelpEntry,        'amp-front/help/help.rb'
    autoload :HelpRegistry,     'amp-front/help/help.rb'
    autoload :CommandHelpEntry, 'amp-front/help/help.rb'
    autoload :FileHelpEntry,    'amp-front/help/help.rb'
  end

  module Plugins
    autoload :Base,     'amp-front/plugins/base.rb'
    autoload :Registry, 'amp-front/plugins/registry.rb'
  end

  autoload :Command, 'amp-front/dispatch/commands/base.rb'
  autoload :ModuleExtensions, 'amp-front/support/module_extensions.rb'
end

autoload :ERB,     'erb'
autoload :Maruku,  'amp-front/third_party/maruku.rb'
autoload :Trollop, 'amp-front/third_party/trollop.rb'