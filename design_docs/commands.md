# Command Dispatch Design Doc

This design document intends to describe how commands will be dispatched
by Amp.

The user's invocations are in the form:

    amp --logging=WARN add --force some_file
    amp config set key value --fiddler="fiddly"
    amp git twiddle --dee="x" --dum="y"
    
## Command classes

Each command is its own class. It must inherit (either directly or indirectly)
from Amp::Command::Base.

Commands are discovered by looking up the class with the name of the requested
command. Thus, the three amp invocations above would run the following (hypothetical)
code to create the command object:

    cmd = Amp::Command::Add.new
    cmd = Amp::Command::Config::Set.new
    cmd = Amp::Command::Git::Twiddle.new
    
## Command Groups

There are a number of commands that will be built into Amp Core: help, add, commit, push,
and so on. These will always be searched first.

Then, we go to command groups. Each plugin comprises a command group, and the Amp::Plugin
subclass that defines a plugin declares a way to access its commands as a group.

Each plugin's command groups are searched using the names provided on the command line, such
as "config set key value --fiddler='fiddly'". Every plugin (hg, git, server, etc.) will be
searched for a "config" command, then a "config set" command, then a "commit set key" command,
and a "config set key value" command. The results are collected, and then only the most
specific matches are kept. If the user has defined a "default command group", and one of the
resulting matches is in that default command group, it is moved to the top of the choice list.
The rest are sorted by how often they have been invoked by the user. This list is presented
to the user, and the user picks which command they intended.

Partial matches *do not match*. Thus, if the user entered:

    amp config --fiddler='fiddly'
    
Then the following commands would match:

    Amp::Command::Config
    Amp::Command::GitPlugin::Config
    Amp::Command::HgPlugin::Config

But the following commands would not:

    Amp::Command::Config::Set
    Amp::Command::Config::Get
    Amp::Command::GitPlugin::Config::Set
    Amp::Command::GitPlugin::Config::Get::ByKey
    
## Command definition

A command definition is roughly as follows:

    command "search" do
      # Define options using Trollop syntax
      opt :verbose, "Verbose output", :type => :boolean
      opt :query, "The query to search for", :type => :string
      
      # Use macros to quickly add features
      has_paging_options
      
      # Add validations
      validates_length_of :query, :in => 4..32
      validates_inclusion_of :query
      validates_has_repository  # validates :repository option
      
      # specify on_run
      on_run do |opts, args|
        repo = opts[:repository]
        p repo.search(opts[:query])
      end
    end