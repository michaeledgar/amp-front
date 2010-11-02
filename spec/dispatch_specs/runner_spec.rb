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

describe Amp::Dispatch::Runner do
  before do
    @runner = Amp::Dispatch::Runner.new(['--version'], :ampfile => "NO SUCH FILE@@@@@@@@@@@@@@@@@@")
  end

  describe '#run!' do
    it 'parses arguments' do
      proc { @runner.run! }.should raise_error(SystemExit)
    end
    
    it 'runs the matching command' do
      mock_command_class = mock('command class')
      mock_command = mock('command')
      Amp::Command.should_receive(:for_name).
                   with('tester --verbose').
                   and_return(mock_command_class)
      mock_command_class.should_receive(:path_parts).and_return(%w{tester})
      mock_command_class.should_receive(:new).and_return(mock_command)
      mock_command.should_receive(:call)
      
      runner = Amp::Dispatch::Runner.new(['tester', '--verbose'])
      runner.run!
    end

    it 'does not crash when no valid command' do
      Amp::Command.should_receive(:for_name).
                   with('').
                   and_return(nil)
      mock_command_class = mock('command class')
      mock_command = mock('command')
      Amp::Command::Help = mock_command_class
      mock_command_class.should_receive(:name).at_most(:once).and_return('Amp::Command::Help')
      mock_command_class.should_receive(:new).and_return(mock_command)
      mock_command.should_receive(:call)

      runner = Amp::Dispatch::Runner.new([''])
      runner.run!
    end
  end
  
  describe '#collect_options' do
    it 'stops un unknown options' do
      arguments = ['help', 'please']
      @runner.collect_options(arguments)
      arguments.should == ['help', 'please']
    end
    
    it 'parses --version automatically and exit' do
      swizzling_stdout do
        proc { @runner.collect_options(['--version', 'please']) }.should raise_error(SystemExit)
      end
    end
    
    it 'displays Amp::VERSION_TITLE with --version' do
      result = swizzling_stdout do
        proc { @runner.collect_options(['--version', 'please']) }.should raise_error(SystemExit)
      end
      result.should include(Amp::VERSION_TITLE)
    end

    it 'returns the parsed options' do
      argopt = @runner.collect_options(['help', 'please'])
      argopt.options.should == {:version => false, :help => false}
    end

    it 'returns the unparsed arguments' do
      argopt = @runner.collect_options(['help', 'please'])
      argopt.arguments.should == ['help', 'please']
    end
  end
end