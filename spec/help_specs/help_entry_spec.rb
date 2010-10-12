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

describe Amp::Help::HelpEntry do
  before(:each) do
    @entry_counter ||= 0
    @entry_counter += 1
    @entry_name = "fake_help_#{@entry_counter}"
  end

  after(:each) do
    Amp::Help::HelpRegistry.entries[@entry_name] = []
  end
  
  describe '#text' do
    it 'equals the text provided in the constructor' do
      entry = Amp::Help::HelpEntry.new(@entry_name, 'abcba')
      entry.text.should == 'abcba'
    end
  end
  
  describe Amp::Help::MarkdownHelpEntry do
    describe '#text' do
      it 'equals the text provided run through the markdown parser' do
        input = '*hello* **there**'
        entry = Amp::Help::MarkdownHelpEntry.new(@entry_name, input)
        output = entry.text
        output.should == "\e[4mhello\e[24m \e[1mthere\e[22m\n\n"
      end
    end
  end
  
  describe Amp::Help::ErbHelpEntry do
    describe '#text' do
      it 'equals the text provided run through ERb' do
        input = '<% 5.times do |x| %><%= x %><% end %>'
        entry = Amp::Help::ErbHelpEntry.new(@entry_name, input)
        output = entry.text
        output.should == "01234"
      end
    end
  end

  describe Amp::Help::CommandHelpEntry do
    describe '#text' do
      it "contains the command's description" do
        @klass = Class.new(Amp::Command::Base) { desc 'foo bar baz' }
        entry = Amp::Help::CommandHelpEntry.new(@entry_name, @klass)
        output = entry.text
        output.should include('foo bar baz')
      end
      
      it "contains the command's options" do
        @klass = Class.new(Amp::Command::Base) do
          opt :force, 'forces something dangerous', :short => '-f'
        end
        entry = Amp::Help::CommandHelpEntry.new(@entry_name, @klass)
        output = entry.text
        output.should include('--force')
        output.should include('forces something dangerous')
        output.should include('-f')
      end
    end
  end
end