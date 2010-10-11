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

describe Amp::Help::HelpRegistry do
  before(:each) do
    @entry_counter ||= 0
    @entry_counter += 1
    @entry_name = "fake_help_#{@entry_counter}"
  end

  after(:each) do
    Amp::Help::HelpRegistry.entries[@entry_name] = []
  end

  describe '#register' do
    it 'makes help entries available through #[]' do
      fake_help_entry = mock(:help_entry)
      Amp::Help::HelpRegistry.register(@entry_name, fake_help_entry)
      Amp::Help::HelpRegistry[@entry_name].should == [fake_help_entry]
    end

    it 'makes help entries availabe through #entries' do
      fake_help_entry = mock(:help_entry)
      Amp::Help::HelpRegistry.register(@entry_name, fake_help_entry)
      Amp::Help::HelpRegistry.entries[@entry_name].should == [fake_help_entry]
    end
  end
  
  describe '#unregister' do
    it 'raises an error when the help entry is not found' do
      lambda {
        Amp::Help::HelpRegistry.unregister('frobnozzle')
      }.should raise_error(ArgumentError)
    end
    
    it 'only needs one argument when a help entry is unambiguous' do
      fake_help_entry = mock(:help_entry)
      Amp::Help::HelpRegistry.entries[@entry_name] = [fake_help_entry]
      # Sanity check before unregistering it
      Amp::Help::HelpRegistry.entries[@entry_name].should == [fake_help_entry]
      Amp::Help::HelpRegistry.unregister(@entry_name)
      Amp::Help::HelpRegistry.entries[@entry_name].should == []
    end

    it 'raises an error when giving 1 argument on an ambiguous match' do
      fake_1, fake_2 = mock(:help_entry), mock(:other_help_entry)
      Amp::Help::HelpRegistry.entries[@entry_name] = [fake_1, fake_2]
      # Sanity check before unregistering it
      Amp::Help::HelpRegistry.entries[@entry_name].should == [fake_1, fake_2]
      lambda {
        Amp::Help::HelpRegistry.unregister(@entry_name)
      }.should raise_error(ArgumentError)
    end

    it 'succeeds when ambiguous matches are clarified' do
      fake_1, fake_2 = mock(:help_entry), mock(:other_help_entry)
      Amp::Help::HelpRegistry.entries[@entry_name] = [fake_1, fake_2]
      # Sanity check before unregistering it
      Amp::Help::HelpRegistry.entries[@entry_name].should == [fake_1, fake_2]
      Amp::Help::HelpRegistry.unregister(@entry_name, fake_2)
      Amp::Help::HelpRegistry.entries[@entry_name].should == [fake_1]
    end
  end
end