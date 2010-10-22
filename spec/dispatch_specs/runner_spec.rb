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
      mock_command_class.should_receive(:inspect).and_return('Amp::Command::Tester')
      mock_command_class.should_receive(:new).and_return(mock_command)
      mock_command.should_receive(:collect_options).and_return([{:verbose => true}, ['--verbose']])
      mock_command.should_receive(:call).with(
          {:verbose => true, :help => false, :version => false}, ['--verbose'])
      
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
      mock_command.should_receive(:collect_options).and_return([{}, []])
      mock_command.should_receive(:call).with(
          {:help => false, :version => false}, [])

      runner = Amp::Dispatch::Runner.new([''])
      runner.run!
    end
  end
  
  describe '#trim_argv_for_command' do
    it 'strips arguments when arguments matches the command name' do
      arguments = ['base', 'help']
      command = mock(:command_class)
      command.should_receive(:inspect).and_return('Amp::Command::Base')
      @runner.trim_argv_for_command(arguments, command).should == ['help']
      arguments.should == ['base', 'help']
    end
    
    it 'strips arguments for commands in namespaces' do
      arguments = ['base', 'help']
      command = mock(:command_class)
      command.should_receive(:inspect).and_return('Amp::Command::Base::Help')
      @runner.trim_argv_for_command(arguments, command).should == []
      arguments.should == ['base', 'help']
    end
    
    it 'raises when the command name does not match arguments' do
      arguments = ['base', 'hello']
      command = mock(:command_class)
      command.should_receive(:inspect).twice.and_return('Amp::Command::Base::Help')
      proc { @runner.trim_argv_for_command(arguments, command) }.should raise_error(ArgumentError)
    end
  end
  
  describe '#collect_options' do
    it 'stops un unknown options' do
      arguments = ['help', 'please']
      options = @runner.collect_options(arguments)
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
      options, arguments = @runner.collect_options(['help', 'please'])
      options.should == {:version => false, :help => false}
    end

    it 'returns the unparsed arguments' do
      options, arguments = @runner.collect_options(['help', 'please'])
      arguments.should == ['help', 'please']
    end
  end
end