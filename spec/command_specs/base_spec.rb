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
    it "sets the instance's options before running on_call" do
      input_opts = {:a => :b}
      received_opts = nil
      @klass.on_call { received_opts = options }
      @klass.new.call(input_opts, nil)
      received_opts.should == input_opts
    end
    
    it "sets the instance's arguments before running on_call" do
      input_args = [1, 2, 3]
      received_args = nil
      @klass.on_call { received_args = arguments }
      @klass.new.call(nil, input_args)
      received_args.should == input_args
    end
  end 
  
  describe '#on_call' do
    it "sets the class's on_call handler when a block is given" do
      flag = false
      @klass.on_call { flag = true }
      @klass.new.call(nil, nil)
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
    context 'with no options specified' do
      it 'returns a nearly empty hash' do
        @klass.new.collect_options.should == {:help => false}
      end
    end
    
    context 'with --verbose specified and not provided' do
      it 'returns :verbose_given => false' do
        opts = nil
        swizzling_argv([]) do
          @klass.opt :verbose, 'Text', :type => :boolean
          opts = @klass.new.collect_options
        end
        opts[:verbose_given].should be_false
      end
    end
    
    context 'with --verbose specified and provided' do
      it 'returns :verbose_given => true, :verbose => true' do
        opts = nil
        swizzling_argv(['--verbose']) do
          @klass.opt :verbose, 'Text', :type => :boolean
          opts = @klass.new.collect_options
        end
        opts[:verbose_given].should be_true
        opts[:verbose].should be_true
      end
    end
  end

  it 'should have a name' do
    @klass.name.should_not be_nil
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