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
Amp::Command.create('help') do |c|
  c.desc "Prints the help for the program."
  
  c.on_call do
    output = ""
    
    cmd_name = arguments.empty? ? "__default__" : arguments.first
    Amp::Help::HelpUI.print_entry(cmd_name, options)
  end
end
