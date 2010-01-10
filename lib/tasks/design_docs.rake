namespace :couchdb do

  # refresh all the design docs on the server
  # e.g. rake refresh_design_docs SERVER="http://127.0.0.1:5984"
  task :refresh_design_docs do
    
    server_location = ENV['SERVER']
    
    svr = CouchRest::Server.new(server_location)
      
    svr.databases.each do |db_name|
      ENV['DATABASE'] = db_name
      Rake::Task["refresh_design_docs_on_db"].execute  
    end
  end

  # refresh design docs for a specific db
  # e.g. rake refresh_design_docs_on_db SERVER="http://127.0.0.1:5984" DATABASE=my_database 
  task :refresh_design_docs_on_db do
  
    db_name = ENV['DATABASE']  
    server_location = ENV['SERVER']
    
    svr = CouchRest::Server.new(server_location)
    db = CouchRest::Database.new(svr, db_name)
 
    ObjectSpace.each_object(Class) do |k| 
      if k.ancestors.include?(CouchRest::ExtendedDocument) && k.name != "CouchRest::ExtendedDocument"     
        ENV['MODEL'] = k.name   
        Rake::Task["refresh_design_doc_for_model"].execute  
      end
    end
  end

  # refresh design docs for a specific db and model
  # e.g. rake refresh_design_doc_for_model SERVER="http://127.0.0.1:5984" DATABASE=my_database MODEL=MyModel
  task :refresh_design_doc_for_model do 
  
    db_name = ENV['DATABASE']
    model_name = ENV['MODEL']
    server_location = ENV['SERVER']
  
    svr = CouchRest::Server.new(server_location)
    db = CouchRest::Database.new(svr, db_name)
  
    puts "MODEL: #{model_name}" 
    model_class = Kernel.const_get(model_name)
    
    if (!["Account","Blog"].include?model_name) # TODO make this more generic? Check for inclusion of database_from_thread module?
      model_class.refresh_design_doc_on(db) 
    else
      model_class.refresh_design_doc
    end
  
  end
end