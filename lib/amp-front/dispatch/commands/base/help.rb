Amp::Command.create('help') do |c|
  c.desc 'Shows this help'
  c.on_run do |opts, args|
    Amp::Command::Base.all_commands.each do |command|
      puts "#{command.name.downcase} - #{command.desc}"
    end
  end
end