namespace :semjo do
  
  desc "creates the couch 'core' database
  e.g. rake couchdb:create_semjo_db COUCH_SERVER='http://127.0.0.1:5984'
  Note: COUCH_SERVER is optional and defaults to localhost"
  task (:create_semjo_db => :environment) do
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984" 
    svr = CouchRest::Server.new(couch_server)   
    svr.create_db("semanticjournal") 
  end
  
  desc "deletes the semanticjournal 'core' database. USE WITH CARE!!
  Note: COUCH_SERVER is optional and defaults to localhost"
  task (:delete_semjo_db => :environment) do
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984"    
    svr = CouchRest::Server.new(couch_server)    
    sitedb = CouchRest::Database.new(svr, "semanticjournal")
    sitedb.delete!
  end
  
  desc "creates a new blog...
  e.g. rake couchdb:create_new_blog RAILS_ENV=development BLOG_NAME=ricroberts BLOG_HOST=ricroberts.com COUCH_SERVER='http://127.0.0.1:5984' 
  Note: BLOG_HOST and COUCH_SERVER are optional. You need to specify the RAILS_ENV so that the blog model knows what server to use for the semanticjournal db
  Remember: if in dev mode, you'll need to also set up an /etc/hosts entry (with ghost gem)"
  task (:create_new_blog => :environment) do
        
    blog_name = ENV['BLOG_NAME']
    blog_host = ENV['BLOG_HOST']
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984"
    
    svr = CouchRest::Server.new(couch_server)    
        
    # make the blog db
    blogdb = CouchRest::Database.new(svr, blog_name)
    blogdb.create!
    
    b = Blog.new    
    b.name = blog_name
    b.hosts = [blog_host] if blog_host
    b.save
    
  end
    
  desc "creates an admin user in the specifed blog, with the specified acct name, first_name, last_name, uri, pwd and email
  e.g. rake couchdb:create_user ACCOUNT_NAME=ric DISPLAY_NAME='ric roberts' PERSONAL_URI='http://swirrl.com/ric.rdf#me' 
  PASSWORD='pwd1' EMAIL='hello@ricroberts.com' BLOG_NAME='ricroberts' COUCH_SERVER='http://127.0.0.1:5984'
  Note: COUCH_SERVER defaults to local server"
  task (:create_user => :environment) do |t, args|
    
    account_name = ENV['ACCOUNT_NAME']
    display_name = ENV['DISPLAY_NAME']
    personal_uri = ENV['PERSONAL_URI']
    password = ENV['PASSWORD']
    email = ENV['EMAIL']
    blog_name = ENV['BLOG_NAME']
    couch_server = ENV['COUCH_SERVER'] || "http://127.0.0.1:5984"
    
    svr = CouchRest::Server.new(couch_server)    
    blogdb = CouchRest::Database.new(svr, blog_name)
    
    acc = Account.get(args.account_name)
    
    unless acc
      puts 'making new account'
      acc = Account.new
      acc.name = account_name
      acc.display_name = display_name
      acc.personal_uri = personal_uri
      acc.email = email
      acc.password = password
      acc.confirm_password = password
      puts success = acc.save
      puts acc.errors.inspect unless success
    end
    
    Thread.current[:blog_db] = blogdb

    bu = BlogUser.new
    bu.account = acc.name
    bu.role = Role::ADMIN_ROLE
    puts bu.database
    puts bu.save
    
  end
  
end