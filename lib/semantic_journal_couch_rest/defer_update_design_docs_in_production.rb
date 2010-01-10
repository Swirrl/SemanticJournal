module SemanticJournalCouchRest::DeferUpdateDesignDocsInProduction
 
  # override the updating of design docs, if the current thread is
  # running in production.
  def update_design_doc(design_doc, db = database)
    saved = db.get(design_doc['_id']) rescue nil
    if saved      
      # If the design doc is already there, don't update it in prod mode. We'll do it manually.
      unless Thread.current[:env] && Thread.current[:env] == :production
        design_doc['views'].each do |name, view|
          saved['views'][name] = view
        end
        db.save_doc(saved)
      end
      saved
    else
      design_doc.database = db
      design_doc.save
      design_doc
    end
  end
  
end