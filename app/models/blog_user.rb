# a user for a particular blog.  
class BlogUser < CouchRest::ExtendedDocument
  
  extend SemanticJournalCouchRest::DeferUpdateDesignDocsInProduction 
  extend SemanticJournalCouchRest::DatabaseFromThread
  include CouchRest::Validation


  property :account #gives us a link to the account doc.
  
  property :role, :cast_as => "String" # the name of the role that this user has in this blog.

  view_by :account
    
  timestamps! #force writing of updated_at and created_at
  

end