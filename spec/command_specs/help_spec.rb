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

describe Amp::Command::Help do
  it 'creates the help command' do
    Amp::Command::Help.should_not be_nil
  end
  
  it 'stores the help command in the all_commands list' do
    Amp::Command::Base.all_commands.should include(Amp::Command::Help)
  end
  
  it 'can be looked up as base help' do
    Amp::Command.for_name('help').should == Amp::Command::Help
  end
  
  it 'prints the help text of all commands' do
    run_command('help').should include('Thanks for using Amp!')
  end
end