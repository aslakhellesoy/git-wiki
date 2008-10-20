require 'spec'

$0 = File.dirname(__FILE__) + '/../../git-wiki.rb' # Otherwise Sinatra will look for views in the wrong place
require 'webrat/sinatra/sinatra_session'
require 'sinatra/test/common'
#require 'couchrest/commands/push'
require File.dirname(__FILE__) + '/../../git-wiki'

World do
  Webrat::SinatraSession.new
end
