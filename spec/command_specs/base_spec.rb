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
require 'amp-front/dispatch/commands/base'

describe Amp::Command::Base do
  before do
    @klass = Class.new(Amp::Command::Base)
  end
  
  describe '#call' do
    def mock_args(args, opts)
      argopt = mock('argument options')
      argopt.should_receive('arguments').once.and_return(args)
      argopt.should_receive('options').once.and_return(opts)
      argopt
    end

    it "sets the instance's options before running on_call" do
      input_opts = {:a => :b}
      received_opts = nil
      @klass.on_call { received_opts = options }
      @klass.new.call(mock_args(nil, input_opts))
      received_opts.should == input_opts
    end
    
    it "sets the instance's arguments before running on_call" do
      input_args = [1, 2, 3]
      received_args = nil
      @klass.on_call { received_args = arguments }
      @klass.new.call(mock_args(input_args, nil))
      received_args.should == input_args
    end
  end 
  
  describe '#on_call' do
    it "sets the class's on_call handler when a block is given" do
      flag = false
      @klass.on_call { flag = true }
      @klass.new.call
      flag.should be_true
    end
    
    it 'returns the current handler if no block is given' do
      @klass.on_call.should == nil
      @klass.on_call { puts 'hello' }
      @klass.on_call.should_not == nil
      @klass.on_call.should respond_to(:call)
    end
  end
  
  describe '#opt' do
    it 'adds an option to the command class' do
      @klass.options.should == []
      @klass.opt :verbose, 'Provide verbose output', :type => :boolean
      @klass.options.should == [[:verbose, 'Provide verbose output',
                                {:type => :boolean}]
                               ]
    end
  end
  
  describe '#collect_options' do
    it 'parses arguments' do
      blank = mock('argument options')
      result = mock('parsed options')
      blank.should_receive(:parse).with([]).and_return(result)
      result.should_receive(:parser)
      @klass.new.collect_options(blank).should == result
    end
  end

  it 'should have a name' do
    @klass.name.should_not be_nil
  end

  it 'knows own command words' do
    def @klass.inspect
      'Amp::Command::Foo::Bar'
    end
    @klass.path_parts.should == ['foo', 'bar']
  end

  describe '#all_commands' do
    it 'should not include nil' do
      @klass.all_commands.should_not include(nil)
    end

    it 'should have itself' do
      @klass.all_commands.should include(@klass)
    end
  end
end