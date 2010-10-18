Feature: Amp command
  In order to see what amp does
  A user will run amp by itself
  to find out what it does

  Scenario: Running amp with no parameters
    When I run dispatch
    Then I should see "Thanks for using Amp!"
