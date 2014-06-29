Feature: WMLAction
  In order to keep my Wesnoth mod up to date
  As a ERA author
  I want to make quick modifications to many WML files

  Scenario: Add and change attributes
    Given a file named "attrs.cfg" with:
    [unit]
      hp=10
      level=1
    [/unit]
    And a file named "attr_mod.cfg" with:
    [unit]
      hp=25
      race="human"
      {REGENERATES}
    [unit]
    When I run "wml_action modify attrs.cfg attr_mod.cfg"
    Then the output should be:
    [unit]
      hp=25
      level=1
      race="human"
      {REGENERATES}
    [unit]


