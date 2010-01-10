class Role < CouchRest::ExtendedDocument
  
  extend SemanticJournalCouchRest::DeferUpdateDesignDocsInProduction 
  
  def self.database
    CouchRest.database("#{COUCH_DB_LOCATION}/semanticjournal")  # the central db
  end
  
  # list of constants representing the different roles
  ADMIN_ROLE = "admin"
  EDITOR_ROLE = "editor"
  CONTRIBUTOR_ROLE = "contributor"
  AUTHOR_ROLE = "author"
    
  # list of constants representing the dfferent rights.  
  CREATE_PAGE_RIGHT = "create_page"
  DELETE_PAGE_RIGHT = "delete_page"
  UPDATE_PAGE_RIGHT = "delete_page"
  PUBLISH_PAGE_RIGHT = "publish_page"
  
  CREATE_ARTICLE_RIGHT = "create_article"
  DELETE_ARTICLE_RIGHT = "delete_article"
  UPDATE_ARTICLE_RIGHT = "delete_article" 
  PUBLISH_ARTICLE_RIGHT = "publish_article"
  
  CREATE_FILE_RIGHT = "create_file"
  DELETE_FILE_RIGHT = "delete_file"
  UPDATE_FILE_RIGHT = "update_file"
  
  MANAGE_USERS = "manage_users"
    
  property :name
  
  property :rights, :cast_as => ['String'] # rights are stored as a collection of strings (of right's names)?
        
end 