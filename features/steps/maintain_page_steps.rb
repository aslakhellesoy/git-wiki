Given /^I am editing "(\w+)"$/ do |page_name|
  visits "/e/#{page_name}"
end

Given /^I add the following body:$/ do |page_body|
  fills_in(:body, :with => page_body) 
end

When /^I save the page$/ do
  clicks_button "Save as the newest version"
end

Then /^I should see "(.*)"$/ do |text|
  response_body.should =~ %r{#{text}}
end

Then /^I should not see "(.*)"$/ do |text|
  response_body.should_not =~ %r{#{text}}
end
