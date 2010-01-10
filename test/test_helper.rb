ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

# re-open these classes, and modify the locations that we use for storing couch data.

module TestDatabaseFromThread
  def database 
    CouchRest.database!("http://127.0.0.1:5984/semanticjournal_blog_test")
  end
end

class Article < CouchRest::ExtendedDocument  
  extend TestDatabaseFromThread
end

class BlogUser < CouchRest::ExtendedDocument
  extend TestDatabaseFromThread
end

class Account < CouchRest::ExtendedDocument
  def self.database
    CouchRest.database!("http://127.0.0.1:5984/semanticjournal_test")  
  end
end

class Blog < CouchRest::ExtendedDocument
  def self.database
    CouchRest.database!("http://127.0.0.1:5984/semanticjournal_test")  
  end
end

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  
  setup :setup_factories

  def setup_factories
    
    # TODO: genericize this, with some metaprogramming?

    Article.all.each do |a|
      a.destroy
    end
   
    Account.all.each do |ac|
      ac.destroy
    end
    
    Blog.all.each do |b|
      b.destroy
    end
    
  end
   
end

