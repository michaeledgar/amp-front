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
##################################################################

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Amp::Dispatch::ArgumentOptions do
  context 'without arguments' do
    before do
      @subject = Amp::Dispatch::ArgumentOptions.new([])
    end

    it 'gives empty arguments' do
      @subject.arguments.should == []
    end

    it 'gives empty options' do
      @subject.options.should == {}
    end

    it 'has no parser' do
      @subject.parser.should be_nil
    end
  end

  context 'with arguments' do
    before do
      @initial_args = %w{--debug help please --verbose}
      @initial_subject = @subject = Amp::Dispatch::ArgumentOptions.new(@initial_args.dup)
    end
    
    it 'preserves arguments' do
      @subject.arguments.should == @initial_args
    end

    it 'initially has no options' do
      @subject.options.should == {}
    end

    context 'after parsing a block' do
      before do
        @subject = @initial_subject.parse do
          banner "Amp - some more crystal, sir?"
          version "Amp version #{Amp::VERSION} (#{Amp::VERSION_TITLE})"
          opt :debug, 'Provide debug output', :type => :boolean
          stop_on_unknown
        end
      end

      it 'accepts trollop blocks' do
        @subject.arguments.should == %w{help please --verbose}
        @subject.options.keys.should be_include(:debug)
        @subject.options[:debug].should be_true
      end

      it 'is idempotent' do
        @initial_subject.arguments.should == @initial_args
        @initial_subject.options.should == {}
      end

      it 'keeps a parser for educate' do
        @subject.parser.should respond_to(:educate)
      end
    end

    context 'removing words' do
      before do
        @subject = Amp::Dispatch::ArgumentOptions.new(%w{help please --verbose})
      end

      context 'removes a word' do
        before do
          @subject_before = @subject
          @subject = @subject.trim_words(['help'])
        end

        it 'removes the word' do
          @subject.arguments.should == %w{please --verbose}
        end

        it 'is idempotent' do
          @subject_before.arguments.should == %w{help please --verbose}
        end
      end

      it 'removes multiple words' do
        parsed = @subject.trim_words(%w{help please})
        parsed.arguments.should == %w{--verbose}
      end

      it 'raises an error on failure' do
        lambda {@subject.trim_words(%w{fred})}.should raise_error(ArgumentError)
      end
    end

    context 'after parsing a list of options' do
      before do
        @initial_args = %w{--verbose blarg --bleep}
        @initial_subject = Amp::Dispatch::ArgumentOptions.new(@initial_args.dup)
        @subject = @initial_subject.parse([
          [:verbose, 'Provide verbose output', {:type => :boolean}],
          [:bleep, 'boop', {:type => :boolean}],
        ])
      end

      it 'parses options' do
        @subject.arguments.should == %w{blarg}
        @subject.options.keys.should be_include(:verbose)
        @subject.options.keys.should be_include(:bleep)
        @subject.options[:verbose].should be_true
      end

      it 'is idempotent' do
        @initial_subject.arguments.should == @initial_args
        @initial_subject.options.should == {}
      end

      it 'keeps a parser for educate' do
        @subject.parser.should respond_to(:educate)
      end
    end

    context 'with options' do
      before do
        @initial_opts = {:foo => 'blarg'}
        @subject = Amp::Dispatch::ArgumentOptions.new(@initial_args.dup, @initial_opts.dup)
      end

      it 'preserves passed in options' do
        @subject.options.should == @initial_opts
      end

      it 'merges options' do
        parsed = @subject.parse do
          opt :debug, 'Provide debug output', :type => :boolean
          stop_on_unknown
        end
        parsed.options.keys.should be_include(:foo)
        parsed.options.keys.should be_include(:debug)
      end
    end

    context 'with same option and argument' do
      let :verbose do
        [:verbose, 'Provide verbose output', {:type => :boolean}]
      end

      def with_verbose(args)
        parsed = Amp::Dispatch::ArgumentOptions.new(args, {:verbose => true}).parse(verbose)
      end

      it 'returns :verbose_given => false' do
        parsed = with_verbose([])
        parsed.options[:verbose_given].should be_false
      end
    
      it 'returns :verbose_given => true, :verbose => true' do
        parsed = with_verbose(['--verbose'])
        parsed.options[:verbose_given].should be_true
        parsed.options[:verbose].should be_true
      end
    end
  end
end
