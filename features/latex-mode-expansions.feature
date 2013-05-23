Feature: LaTeX-mode expansions
  Background:
    Given there is no region selected
    And I turn on LaTeX-mode

  Scenario: Mark simple math
    Given there is no region selected
    And I turn on LaTeX-mode
    When I insert:
    """
    blah blah
    blah $E=mc^2$
    blah
    """
    And I place the cursor between "blah " and "$"
    And I press "C-@"
    Then the region should be "E"
    And I press "C-@"
    Then the region should be "E=mc"
    And I press "C-@"
    Then the region should be "$E=mc^2$"

  Scenario: Mark enclosing $$
    When I insert "qffd $E=mc^2$"
    And I place the cursor before "$E"
    And I press "C-@"
    Then the region should be "$E=mc^2$"

  Scenario: Mark enclosing $$
    When I insert "blah blah $E=mc^2$ blah blah"
    And I place the cursor between "$" and " blah"
    And I press "C-@"
    Then the region should be "$E=mc^2$"





