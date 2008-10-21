require 'spec'

$0 = File.dirname(__FILE__) + '/../../couchrest-wiki.rb' # Otherwise Sinatra will look for views in the wrong place
require 'webrat/sinatra/sinatra_session'
require 'sinatra/test/common'
require File.dirname(__FILE__) + '/../../couchrest-wiki'

World do
  Webrat::SinatraSession.new
end

Before do
  CouchRest.delete(CouchUrl)
  CouchRest.database!(CouchUrl)
end
