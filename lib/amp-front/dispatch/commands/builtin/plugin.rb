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
Amp::Command.namespace 'plugin' do
  Amp::Command.create('list') do |c|
    c.desc "Lists all the plugins known to Amp."
  
    c.on_run do |options, args|
      Amp::Plugins::Base.all_plugins.each do |plugin|
        puts plugin.name
      end
    end
  end
end