module SemanticJournalCouchRest::DatabaseFromThread
 
  def database 
    Thread.current[:blog_db]
  end
  
end