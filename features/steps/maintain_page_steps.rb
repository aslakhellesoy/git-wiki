Given /^I am editing "(.+)"$/ do |page_name|
  visits "/e/#{page_name}"
end

Given /^I add the following body:$/ do |page_body|
  fills_in(:body, :with => page_body) 
end

Given /^I add tags "(.+)"$/ do |tags|
  fills_in(:tags, :with => tags)
end

When /^I save the page$/ do
  clicks_button "Save as the newest version"
end

When /^I go to the list page$/ do
  visits "/_list"
end

When /^I go to "(.+)"$/ do |path|
  visits path
end

When /^I follow "(.+)"$/ do |link|
  clicks_link link
end

Then /^I should see "(.+)"$/ do |text|
  response_body.should =~ Regexp.new(Regexp.escape(text))
end

Then /^I should not see "(.+)"$/ do |text|
  response_body.should_not =~ Regexp.new(Regexp.escape(text))
end

Then /^I should see within "(.+)":$/ do |selector, html|
  # TODO: Make this work with Hpricot
end
