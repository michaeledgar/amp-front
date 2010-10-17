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
require 'amp-front/dispatch/commands/base.rb'

describe Amp::Command do
  it 'should fail to look up a nonexistent command' do
    Amp::Command.for_name('sillyzargbyl --verbose').should be_nil
  end

  context 'when created with a specific name' do
    before do
      @name = next_name
      @command_name = @name.capitalize
      @class = Amp::Command.create(@command_name) do |c|
        c.desc 'Hello'
        c.opt :verbose, "Verbose output", :type => :boolean
      end
    end
    
    it 'creates the named class as a submodule of Amp::Command' do
      Amp::Command.const_get(@command_name).should == @class
    end
    
    it 'uppercases the first letter of the name' do
      klass = Amp::Command.create('search0') {|c| }
      Amp::Command.const_get('Search0').should == klass
    end
    
    it 'stores the new subclass in the all_commands list' do
      Amp::Command::Base.all_commands.should include(@class)
    end
    
    it 'can be looked up by for_name' do
      Amp::Command.for_name(@command_name).should == @class
    end
    
    it "doesn't crash if you have an odd argument" do
      # The hyphen cause const_defined? to bail at one point since it's
      # not allowed in module names
      Amp::Command.for_name("#{@command_name} new-commands").should == @class
    end
    
    it 'can be looked up by a set of command line arguments' do
      Amp::Command.for_name("#{@command_name} show --verbose").should == @class
    end
    
    it 'has a description' do
      @class.desc.should == 'Hello'
    end
    
    it 'has a name' do
      @class.name.should == @command_name
    end
  end
  
  context 'when created within a namespace' do
    before do
      @name = next_name
      Amp::Command.namespace 'TempNamespace' do
        @class = Amp::Command.create(@name) do |c|
          c.opt :verbose, "Verbose output", :type => :boolean
        end
      end
    end
    
    it 'should create the requested namespace as a module' do
      Amp::Command::Tempnamespace.should_not be_nil
    end
    
    it "should create the command in the namespace's module" do
      Amp::Command::Tempnamespace.const_get(@name.capitalize).should == @class
    end
    
    it 'can be looked up by for_name with the nested command syntax' do
      Amp::Command.for_name("tempnamespace #{@name.downcase}").should == @class
    end
  end 

  context 'when no name given' do
    it 'should return Amp::Command' do
      Amp::Command.for_name('').should == Amp::Command
    end
  end
end