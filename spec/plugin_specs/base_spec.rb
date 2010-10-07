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

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Amp::Plugins::Base do
  it 'yields itself for easy configuration' do
    new_plugin = Amp::Plugins::Base.create('silly') do |plugin|
      plugin.author = 'Michael Edgar'
    end
    new_plugin.author.should == 'Michael Edgar'
  end
  
  it 'mentions its author when inspected' do
    plugin = Amp::Plugins::Base.create('silly') do |plugin|
      plugin.author = 'adgar@carboni.ca'
    end
    plugin.new.inspect.should include('adgar@carboni.ca')
  end
  
  it 'infers its own module name' do
    plugin = Amp::Plugins::Base.create('silly')
    plugin.new.module.should == 'Amp::Plugins::Silly'
  end
end