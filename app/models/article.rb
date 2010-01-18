class Article < CouchRest::ExtendedDocument
    
  DRAFT_STATUS = "draft"
  PENDING_REVIEW_STATUS = "pending review"
  PUBLISHED_STATUS = "published"
 
  extend SemanticJournalCouchRest::DeferUpdateDesignDocsInProduction 
  extend SemanticJournalCouchRest::DatabaseFromThread
  include CouchRest::Validation

  property :permalink
  property :title
  property :raw, :cast_as => :boolean #don't run content through textilizer.
  property :published_at, :cast_as => 'Time'
  property :content
  property :clean_content # use for the content, stripped of all markup - for searching, etc.
  property :status
  property :published_by #account name of who published the article
  property :sanitized_title
  
  view_by :sanitized_title
  view_by :permalink
  
  view_by :published_at, :descending => true,
    :map => 
      "function(doc) {
        if ((doc['couchrest-type'] == 'Article') && doc['published_at']) {
          emit(doc['published_at'], 1);
        }
      }",
     :reduce =>
        "function(keys, values, rereduce) {
          return sum(values);
        }"

  view_by :created_at, :descending => true
  
  timestamps!
  
  validates_present :title
  validates_length :title, :within => 3..255
  
  before_save :generate_permalink_from_title
  
  attr_accessor :permalink_updated
  
  # TODO: make this a bit more intelligent
  def set_published(published, account_name)
    if published && self.published_at == nil 
      # notice: only change the published at time and user if publishing for first time.
      self.published_at = Time.now.utc
      self.published_by = account_name
    elsif published == false
      self.published_at = nil
      self.published_by = account_name
    end
    # otherwise do nothing
  end
  
  def is_published?
    !!self.published_at
  end
  
  # special setter for permalink
  def set_permalink(new_permalink)
    new_permalink = Article.sanitize_permalink(new_permalink) # make sure it's sanitized
    if new_permalink != self.permalink # only bother doing anything if it's actually changed.     
      self.permalink = new_permalink
      self.permalink_updated = true # make a note that we're changing the permalink
    end
  end
  
  def generate_permalink_from_title      
    if self.new_document?
      self.sanitized_title = Article.sanitize_permalink(title)
      self.permalink = self.sanitized_title
    end
    
    # if it's a new doc, or we're manually forcing the permalink change....
    if self.new_document? || self.permalink_updated
      check_permalink_uniqueness
    end
  end
  
  def self.sanitize_permalink(the_permalink)
    the_permalink.downcase.gsub(/[^a-z0-9]/,'-').squeeze('-').gsub(/^\-|\-$/,'') #sanitize
  end
  
  def check_permalink_uniqueness    
    # find other docs with the same sanitized title
    other_occurrences = Article.by_sanitized_title(:key => self.sanitized_title)
    
    if other_occurrences.length > 0 
      suffix = "-#{other_occurrences.length}"
      if self.new_document?
        self.permalink += suffix # if there's a duplicate, add a suffix.
      else
        # if it's not a new document, then it's ok if the other occurrence is ourselves
        unless (other_occurrences.length == 1 && other_occurrences[0].id == self.id)
          self.permalink += suffix 
        end  
      end
    end
  end
  
  def self.get_paginated_articles(pagination_options = {:per_page => 5, :page => 1})
    @database = database
    options = {:design_doc => 'Article', :view_name => 'by_published_at', :reduce => false, :descending => true, :include_docs => true}
    options.merge! pagination_options
    self.paginate(options)
  end
  
                   
end
