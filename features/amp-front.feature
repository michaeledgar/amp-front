Feature: Help Command
  In order to learn to use Amp
  A user can use the help command
  to be delivered useful information

  Scenario: Running help with no parameters
    Given the argument help
    When I run dispatch
    Then I should see "Thanks for using Amp!"

  Scenario: Running help commands
    Given the argument help
    And the argument commands
    When I run dispatch
    Then I should see "Prints the help for the program."
    And I should see "^help"
  
  Scenario: Running help ampfiles
    Given the argument help
    And the argument ampfiles
    When I run dispatch
    Then I should see "What'?s an Ampfile?"

  Scenario: Running help new-commands
    Given the argument help
    And the argument new-commands
    When I run dispatch
    Then I should see "commands are the driving force behind"
