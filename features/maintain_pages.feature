Feature: Maintain pages

  Scenario: Add page
    Given I am editing "FirstPost"
    And I add the following body:
      "h2. First post!

      * hello
      * world"
    When I save the page
    Then I should see "First post!"