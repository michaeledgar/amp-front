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

describe Amp::Command::Validations do
  before do
    @klass = Amp::Command.create(next_name) do |command|
      command.before do |opts,args|
        opts[:hello] && args.size >= 1
      end
      command.after do |opts,args|
        !opts[:world]
      end
    end
  end
  
  context '#valid?' do
    it 'runs before blocks to check validity' do
      instance = @klass.new
      instance.should be_valid({:hello => true}, ['stuff'])
      instance.should_not be_valid({:hello => false}, ['stuff'])
      instance.should_not be_valid({:hello => true}, [])
    end
  end
  
  context '#run_after' do
    it 'runs the after blocks' do
      instance = @klass.new
      instance.run_after({:world => false}, []).should be_true
      instance.run_after({:world => true}, []).should be_false
    end
  end
  
  context '#validates_each' do
    before do
      @class = Amp::Command.create(next_name) do |c|
        c.validates_each(:hello, :world) do |opts, key, value|
          value > 0
        end
      end
    end
    
    it 'runs the validation block on the named options' do
      instance = @class.new
      instance.should be_valid({:hello => 3, :world => 5},[])
      instance.should_not be_valid({:hello => -3, :world => 5},[])
      instance.should_not be_valid({:hello => 3, :world => -5},[])
    end
  end
  
  context '#validates_block' do
    before do
      @class = Amp::Command.create(next_name) do |c|
        c.validates_block(:unless => :some_method) do |opts, args|
          args.size == 0
        end
      end

      @class.send(:define_method, :some_method) do |opts, args|
        opts[:skip_validation]
      end
    end
    
    it 'only runs the validation when some_method returns true' do
      instance = @class.new
      instance.should be_valid({:skip_validation => false}, [])
      instance.should be_valid({:skip_validation => true},  [])
      instance.should be_invalid({:skip_validation => false}, [5])
      instance.should be_valid({:skip_validation => true},  [5])
    end
  end
  
  context '#validates_presence_of' do
    before do
      @class = Amp::Command.create(next_name) do |c|
        c.validates_presence_of :hello
      end
    end
    
    it 'runs the validation block on the named options' do
      instance = @class.new
      instance.should be_valid({:hello => 3, :hello_given => true},[])
      instance.should be_invalid({:hello => 3, :hello_given => false},[])
      instance.should be_valid({:hello => nil, :hello_given => true},[])
      instance.should be_invalid({:hello => nil, :hello_given => false},[])
    end
  end
  
  context '#validates_inclusion_of' do
    before do
      @class = Amp::Command.create(next_name) do |c|
        c.validates_inclusion_of(:hello, :in => 3..15)
        c.validates_inclusion_of(:world, :in => %w[mike ari])
      end
    end
    
    it 'runs the validation block on the named options' do
      instance = @class.new
      instance.should be_valid({:hello => 3, :world => 'mike'},[])
      instance.should be_invalid({:hello => -1, :world => 'ari'},[])
      instance.should be_invalid({:hello => 5, :world => 'steve'},[])
    end
    
    it 'fails when no options hash is provided' do
      proc {
        Amp::Command.create(next_name) do |c|
          c.validates_inclusion_of(:temp)
        end
      }.should raise_error(ArgumentError)
    end
    
    it 'handles being parameterized by :if' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_inclusion_of(:temp, :in => 3..15, :if => proc {|opts,args| args.size >= 1})
      end
      
      instance = klass.new
      instance.should be_valid({:temp => 5}, ['hello'])
      instance.should be_valid({:temp => 1}, [])
      instance.should be_invalid({:temp => 1}, ['hello'])
    end
  end
  
  context '#validates_length_of' do    
    it 'runs the validation block handling :in and :within' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_length_of(:hello, :in => 3..15)
        c.validates_length_of(:world, :within => 13..25)
      end
      instance = klass.new
      instance.should be_valid({:hello => 'a' * 3, :world => 'a' * 24},[])
      instance.should be_invalid({:hello => 'a' * 1, :world => 'a' * 19},[])
      instance.should be_invalid({:hello => 'a' * 5, :world => 'a' * 3},[])
    end
    
    it 'runs the validation block handling :maximum' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_length_of(:hello, :maximum => 10)
      end
      instance = klass.new
      instance.should be_valid({:hello => 'a' * 8},[])
      instance.should be_valid({:hello => 'a' * 10},[])
      instance.should be_invalid({:hello => 'a' * 11},[])
      instance.should be_valid({:hello => ''},[])
    end
    
    it 'runs the validation block handling :minimum' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_length_of(:hello, :minimum => 10)
      end
      instance = klass.new
      instance.should be_valid({:hello => 'a' * 12},[])
      instance.should be_valid({:hello => 'a' * 10},[])
      instance.should be_invalid({:hello => 'a' * 9},[])
      instance.should be_invalid({:hello => ''},[])
    end
    
    it 'runs the validation block handling :is' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_length_of(:hello, :is => 4)
      end
      instance = klass.new
      instance.should be_valid({:hello => 'a' * 4},[])
      instance.should be_invalid({:hello => 'a' * 5},[])
      instance.should be_invalid({:hello => 'a' * 3},[])
      instance.should be_invalid({:hello => ''},[])
    end
    
    it 'fails when no length keys are provided' do
      proc {
        Amp::Command.create(next_name) do |c|
          c.validates_length_of(:temp, {})
        end
      }.should raise_error(ArgumentError)
    end
    
    it 'handles being parameterized by :if' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_length_of(:temp, :in => 3..15, :if => proc {|opts,args| args.size >= 1})
      end
      
      instance = klass.new
      instance.should be_valid({:temp => 'a' * 5}, ['hello'])
      instance.should be_valid({:temp => 'a' * 1}, [])
      instance.should be_invalid({:temp => 'a' * 1}, ['hello'])
    end
  end
  
  
  context '#validates_argument_count' do    
    it 'runs the validation block handling :in and :within' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_argument_count(:in => 1..2)
      end
      instance = klass.new
      instance.should be_valid({}, [3] * 1)
      instance.should be_invalid({}, [3] * 3)
      instance.should be_invalid({}, [])
    end
    
    it 'runs the validation block handling :maximum' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_argument_count(:maximum => 10)
      end
      instance = klass.new
      instance.should be_valid({},[3] * 8)
      instance.should be_valid({},[3] * 10)
      instance.should be_invalid({},[3] * 11)
      instance.should be_valid({},[])
    end
    
    it 'runs the validation block handling :minimum' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_argument_count(:minimum => 10)
      end
      instance = klass.new
      instance.should be_valid({},[3] * 12)
      instance.should be_valid({},[3] * 10)
      instance.should be_invalid({},[3] * 9)
      instance.should be_invalid({},[])
    end
    
    it 'runs the validation block handling :is' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_argument_count(:is => 4)
      end
      instance = klass.new
      instance.should be_valid({},[3] * 4)
      instance.should be_invalid({},[3] * 3)
      instance.should be_invalid({},[3] * 5)
      instance.should be_invalid({},[])
    end
    
    it 'fails when no length keys are provided' do
      proc {
        Amp::Command.create(next_name) do |c|
          c.validates_argument_count
        end
      }.should raise_error(ArgumentError)
    end
    
    it 'handles being parameterized by :if' do
      klass = Amp::Command.create(next_name) do |c|
        c.validates_argument_count(:in => 2..3, :unless => proc {|opts,args| args[0] == 'off'})
      end
      
      instance = klass.new
      instance.should be_valid({}, ['hello', 'world'])
      instance.should be_valid({}, ['off'])
      instance.should be_invalid({}, ['hello'])
    end
  end
end
  