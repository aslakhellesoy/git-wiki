require 'rubygems'
require 'cucumber/rake/task'

task :default => :setup

desc 'Add default content.'
task :setup do
  require 'sinatra'
  require 'sinatra/test/common' # Prevent app from running
  require File.dirname(__FILE__) + '/couchrest-wiki'
  prefix = File.dirname(__FILE__) + '/default/'
  Dir[prefix + '**/*'].each do |path|
    name = path[prefix.length..-1]
    p = Page.find_or_create(name)
    p['body'] = IO.read(path)
    p.save
  end
end

Cucumber::Rake::Task.new do |t|
  t.rcov = true
end
