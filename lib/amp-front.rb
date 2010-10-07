module Amp
  VERSION = '0.0.1'
  VERSION_TITLE = 'Koyaanisqatsi'
  
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
  module Command
    autoload :Base, 'amp-front/dispatch/commands/base.rb'
    autoload :Validations, 'amp-front/dispatch/commands/validations.rb'
  end
  module Dispatch
    autoload :Runner, "amp-front/dispatch/runner.rb"
  end
  module Plugins
    autoload :Base,     'amp-front/plugins/base.rb'
    autoload :Registry, 'amp-front/plugins/registry.rb'
  end
  autoload :ModuleExtensions, 'amp-front/support/module_extensions.rb'
end

autoload :Trollop, 'amp-front/third_party/trollop.rb'