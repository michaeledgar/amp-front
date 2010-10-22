# Amp Dependancies Design Doc

Amp has so far avoided Rubygems dependancies, due to performance concerns.
Required libraries are included wholesale; so far all such libraires have
been modified in some way.

## Dependancies

### Maruku

Maruku is a pure ruby markdown interpreter.
Amp uses a highly hacked version of Maruku
(it adds an output form with ANSI color codes)
that was trimmed down to try to make it lightweight.

### Trollop

Trollop is a command-line parsing library.
It didn't originally expose its --help behavior,
which is really nice because it lists options automatically.
The Amp version exposes the parser object so we can run parser.educate!.

## The Case Against Rubygems

Loading Rubygems on each invocation of amp adds at least 150-500ms+ to each invocation.
With the current plugin architecture, we require users to either use rubygems,
or individually download each repo and load plugins manually using their Ampfile.
An installer script down the line could automate the latter option.

### Bundler

Bundler (require 'bundler/setup') adds another 400ms+ to startup time.
A Gemfile is used to streamline gem installation, but it is not used by
Amp itself.

