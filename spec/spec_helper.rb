require 'rack/test'
Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each { |file| require file }
require (File.dirname(__FILE__) + '/../app.rb')