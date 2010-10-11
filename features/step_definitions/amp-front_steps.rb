Given /the argument (.*)/ do |arg|
  @arguments ||= []
  @arguments << arg
end

When /I run dispatch/ do
  dispatch = Amp::Dispatch::Runner.new(@arguments || [])
  @result = swizzling_stdout { dispatch.run! }
end

Then /I should see "(.*)"/ do |arg|
  @result.should =~ /#{arg}/
end

def swizzling_stdout
  new_stdout = StringIO.new
  $stdout, old_stdout = new_stdout, $stdout
  yield
  new_stdout.string
ensure
  $stdout = old_stdout
  new_stdout.string
end