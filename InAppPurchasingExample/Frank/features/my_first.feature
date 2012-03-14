Feature: 
  As a user
  I want to access a list of products
  So I can see whats for sale

Background: 
    Given I launch the app
    
Scenario: Accessing the product listing
    When I touch the button marked "Load Products"
    Then I wait to see a navigation bar titled "Products"

Scenario: Accessing the product list and returning to the menu
    When I touch the button marked "Load Products"
    Then I wait to see a navigation bar titled "Products"
    When I touch the button marked "Back"
    Then I wait to see a navigation bar titled "InAppPurchasingExample"
