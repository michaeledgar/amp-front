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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def run_command(command, opts={}, args=[])
  swizzling_stdout do
    Amp::Command.for_name(command).new.call(opts, args)
  end
end


def next_name
  # Shared by all subclasses.
  @@__next_name_counter ||= 0
  @@__next_name_counter += 1
  "TempClass#{@@__next_name_counter}"
end

def swizzling_argv(argv)
  old_argv = ARGV.dup
  ARGV.replace(argv)
  yield
ensure
  ARGV.replace(old_argv)
end