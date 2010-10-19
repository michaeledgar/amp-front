Feature: Plugin List Command
  In order to check my plugins
  A user can use the "plugin list" command
  to inspect the Amp runtime environment

  Scenario: Running plugin list with no parameters
    Given the argument plugin
    And the argument list
    When I run dispatch
    Then I should see "Amp::Plugins::Base"