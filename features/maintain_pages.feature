Feature: Maintain pages

  Scenario: Add page
    Given I am editing "FirstPost"
    And I add the following body:
      "h2. First post!

      * hello
      * world
      
      WikiLink
      "
    When I save the page
    Then I should see "First post!"
    
  Scenario: View ul list
    GivenScenario Add page
    Then I should see within "ul":
      "<ul>
      	<li>hello</li>
      	<li>world</li>
      </ul>"

  Scenario: View page list
    Given I am editing "SecondPost"
    And I add the following body:
      "h2. Second post!"
    When I save the page
    And I go to the list page
    Then I should see "SecondPost"