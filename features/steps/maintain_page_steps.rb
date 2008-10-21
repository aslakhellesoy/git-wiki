Given /^I am editing "(\w+)"$/ do |page_name|
  visits "/e/#{page_name}"
end

Given /^I add the following body:$/ do |page_body|
  fills_in(:body, :with => page_body) 
end

Given /^I add tags "(.*)"$/ do |tags|
  fills_in(:tags, :with => tags)
end

When /^I save the page$/ do
  clicks_button "Save as the newest version"
end

When /^I go to the list page$/ do
  visits "/_list"
end

When /^I follow "(.*)"$/ do |link|
  clicks_link link
end

Then /^I should see "(.*)"$/ do |text|
  response_body.should =~ %r{#{text}}
end

Then /^I should not see "(.*)"$/ do |text|
  response_body.should_not =~ %r{#{text}}
end

Then /^I should see within "(.*)":$/ do |selector, html|
  # TODO: Make this work with Hpricot
end
