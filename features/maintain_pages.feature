Feature: Maintain pages

  Scenario: Add page
    Given I am editing "FirstPost"
    And I add the following body:
      "h2. First post!

      * hello
      * world
      
      WikiLink
      "
    And I add tags "one two three"
    When I save the page
    Then I should see "First post!"

  Scenario: View page list
    Given I am editing "SecondPost"
    And I add the following body:
      "h2. Second post!"
    And I add tags "two three"
    When I save the page
    And I go to the list page
    Then I should see "SecondPost"

  Scenario: navigate tag cloud
    GivenScenario Add page
    GivenScenario View page list
    When I follow "one"
    Then I should see "FirstPost"
    And I should not see "SecondPost"