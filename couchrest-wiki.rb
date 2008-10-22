#!/usr/bin/env ruby
require 'rubygems'

%w(sinatra
couchrest
haml
sass
redcloth).each { |dependency| require dependency }

begin
  require 'thin'
rescue LoadError
  puts '# May I suggest you to use Thin?'
end

class String
  def to_html
    RedCloth.new(self).to_html
  end

  def auto_link
    self.gsub(/<((https?|ftp|irc):[^'">\s]+)>/xi, %Q{<a href="\\1">\\1</a>})
  end

  def wiki_link
    self.gsub(/([A-Z][a-z]+[A-Z][A-Za-z0-9]+)/) do |page|
      %Q{<a class="#{Page.css_class_for(page)}" href="/#{page}">#{page.titleize}</a>}
    end
  end

  def titleize
    self.gsub(/([A-Z]+)([A-Z][a-z])/,'\1 \2').gsub(/([a-z\d])([A-Z])/,'\1 \2')
  end

  def without_ext
    self.sub(File.extname(self), '')
  end
end

class PageNotFound < Sinatra::NotFound
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Page < CouchRest::Model
  view_by :name

  view_by :tags,
    :map =>
      "function(doc) {
        if (doc['couchrest-type'] == 'Page' && doc.tags) {
          doc.tags.forEach(function(tag){
            emit(tag, doc);
          });
        }
      }",
    :reduce =>
      "function(keys, values, rereduce) {
        return values.length;
      }"

  class << self
    def find(name)
      doc = by_name(:key => name)[0]
      raise PageNotFound.new(name) unless doc
      new(doc)
    end

    def find_or_create(name)
      find(name)
    rescue PageNotFound
      new(:name => name)
    end

    def css_class_for(name)
      find(name)
      'exists'
    rescue PageNotFound
      'unknown'
    end
  end

  def to_html
    content.auto_link.wiki_link.to_html
  end

  def to_s
    name
  end

  def name
    self['name']
  end

  def body
    self['body']
  end

  def tags
    self['tags'] || []
  end

  def content
    body
  end
  
  def content_type
    ext = File.extname(name)[1..-1]
    Rack::File::MIME_TYPES[ext]
  end

end

use_in_file_templates!

configure do
  CouchUrl = "http://localhost:5984/couchrest-wiki"
  Homepage = 'Home'
  set_option :haml,  :format        => :html4,
                     :attr_wrapper  => '"'

  RedCloth::Formatters::HTML.module_eval do
    def br(opts)
      '<br>'
    end
  end

  Page.use_database(CouchRest.database!(CouchUrl))
end

error PageNotFound do
  page = request.env['sinatra.error'].name
  redirect "/e/#{page}"
end

helpers do
  def title(title=nil)
    @title = title.to_s unless title.nil?
    @title
  end

  def list_item(page)
    '<a class="page_name" href="/%s">%s</a>' % [page, page.name.titleize]
  end

  def partial(name, options={})
    haml name, options.merge(:layout => false)
  end
end

before do
  content_type 'text/html', :charset => 'utf-8'

  @tags = Page.by_tags(:reduce => true, :group => true)['rows']
end

get '/' do
  redirect '/' + Homepage
end

get '/_stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/_list' do
  @pages = params[:tag] ? Page.by_tags(:key => params[:tag]) : Page.all
  haml :list
end

get '/e/*' do
  name = params[:splat][0]
  @page = Page.find_or_create(name)
  haml :edit
end

get '/*' do
  name = params[:splat][0]
  @page = Page.find(name)
  if @page.content_type
    send_data @page.body, :type => @page.content_type, :disposition => 'inline'
  else
    haml :show
  end
end

post '/e/*' do
  name = params[:splat][0]
  @page = Page.find_or_create(name)
  params['tags'] = params['tags'].split(' ').map{|tag| tag.strip}
  @page.merge!(params)
  @page.save
  redirect "/#{@page}"
end

__END__
@@ layout
!!! strict
%html
  %head
    %title= title
    %link{:rel => 'stylesheet', :href => '/_stylesheet.css', :type => 'text/css'}
    %script{:src => '/jquery-1.2.3.min.js', :type => 'text/javascript'}
    %script{:src => '/jquery.hotkeys.js', :type => 'text/javascript'}
    %script{:src => '/to-title-case.js', :type => 'text/javascript'}
    :javascript
      $(document).ready(function() {
        $.hotkeys.add('Ctrl+h', function() { document.location = '/#{Homepage}' })
        $.hotkeys.add('Ctrl+l', function() { document.location = '/_list' })

        /* title-case-ification */
        document.title = document.title.toTitleCase();
        $('h1:first').text($('h1:first').text().toTitleCase());
        $('a').each(function(i) {
          var e = $(this)
          e.text(e.text().toTitleCase());
        })
      })
  %body
    #content= yield
    #tag_cloud= partial(:tag_cloud)

@@ tag_cloud
Tags:
- @tags.each do |tag|
  %a{:href => "/_list?tag=#{tag['key']}", :style => "font-size: #{tag['value']}em;"}= tag['key']

@@ show
- title @page.name.titleize
:javascript
  $(document).ready(function() {
    $.hotkeys.add('Ctrl+e', function() { document.location = '/e/#{@page}' })
  })
%h1#page_title= title
#page_content
  ~"#{@page.to_html}"

@@ edit
- title "Editing #{@page.name.titleize}"
%h1= title
%form{:method => 'POST', :action => "/e/#{@page}"}
  %p
    %textarea{:name => 'body'}= @page.content
  %p
    %input{:name => 'tags', :value => @page.tags.join(' ')}
  %p
    %input.submit{:type => :submit, :value => 'Save as the newest version'}
    or
    %a.cancel{:href=>"/#{@page}"} cancel

@@ list
- title "Listing pages"
%h1#page_title All pages
- if @pages.empty?
  %p No pages found.
- else
  %ul#pages_list
    - @pages.each_with_index do |page, index|
      - if (index % 2) == 0
        %li.odd=  list_item(page)
      - else
        %li.even= list_item(page)

@@ stylesheet
body
  :font
    family: "Lucida Grande", Verdana, Arial, Bitstream Vera Sans, Helvetica, sans-serif
    size: 14px
    color: black
  line-height: 160%
  background-color: white
  margin: 0 10px
  padding: 0
h1#page_title
  font-size: xx-large
  text-align: center
  padding: .9em
h1
  font-size: x-large
h2
  font-size: large
h3
  font-size: medium
a
  padding: 2px
  color: blue
  &.exists
    &:hover
      background-color: blue
      text-decoration: none
      color: white
  &.unknown
    color: gray
    &:hover
      background-color: gray
      color: white
      text-decoration: none
  &.cancel
    color: red
    &:hover
      text-decoration: none
      background-color: red
      color: white
blockquote
  background-color: #f9f9f9
  padding: 5px 5px
  margin: 0
  margin-bottom: 2em
  outline: #eee solid 1px
  font-size: 0.9em
  cite
    font-weight: bold
    padding-left: 2em
code
  background-color: #eee
  font-size: smaller
pre
  padding: 5px 5px
  overflow: auto
  font-family: fixed
  line-height: 1em
  border-right: 1px solid #ccc
  border-bottom: 1px solid #ccc
  background-color: #eee
textarea
  font-family: courrier
  font-size: .9em
  border: 2px solid #ccc
  display: block
  padding: .5em
  height: 37em
  width: 100%
  line-height: 18px
input.submit
  font-weight: bold

#content
  max-width: 48em
  margin: auto
  padding: 2em
ul#pages_list
  list-style-type: none
  margin: 0
  padding: 0
  li
    padding: 5px
    &.odd
      background-color: #D3D3D3
    a
      text-decoration: none
.highlight
  background-color: #f8ec11
.done
  font-size: x-small
  color: #999
