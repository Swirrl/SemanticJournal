class Blog < CouchRest::ExtendedDocument
  
  extend SemanticJournalCouchRest::DeferUpdateDesignDocsInProduction 

  def self.database
    CouchRest.database("#{APP_CONFIG['couch_db_location']}/semanticjournal")  # the central db
  end
  
  property :name
  property :hosts
  property :html5, :cast_as => :boolean, :default => false

  view_by :name 

  # call with :key => 'host' to get all the blogs that use that host (should only really be 1)
  # call with :key => 'host' and :reduce => true to see how many times a tag has been used
  # call with :group => true and :reduce => true to get all of the unique hosts that exist in the system.  
  view_by :hosts, 
    :map => 
      "function(doc) {
        if (doc['couchrest-type'] == 'Blog' && doc.hosts) {
          doc.hosts.forEach(function(host){
            emit(host, 1);
          });
        }
      }",
     :reduce =>
        "function(keys, values, rereduce) {
          return sum(values);
        }"
        
  def canonical_url
    if hosts && hosts.length > 0
      return hosts[0]
    else
      raise RuntimeError.new("no hosts for blog")
    end
  end
   
end
