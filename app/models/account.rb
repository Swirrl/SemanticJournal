# this is the top-level document that stores info about the user, i.e. email, name etc.
class Account < CouchRest::ExtendedDocument
 
  extend SemanticJournalCouchRest::DeferUpdateDesignDocsInProduction 
  include CouchRest::Validation
  
  def self.database
    CouchRest.database("#{APP_CONFIG['couch_db_location']}/semanticjournal")  # the central db
  end

  # WE USE THE ACCOUNT NAME AS THE ID. 
  # This is the only model for which we do this, so no need to scope it 
  # (even if we do use non GUIDs for other model IDs, we can just scope them, and they won't overlap)
  unique_id :name
  
  property :name # the UNIQUE account name, by which we can identify the person to others (without having to reveal email address)
  
  property :display_name
  
  property :email
  property :active, :cast_as => :boolean, :default => true

  property :password_hash
  property :password_salt

  property :personal_uri
      
  view_by :email
  
  view_by :active_email,
    :map => "
      function(doc) {
        if ((doc['couchrest-type'] == 'Account') && doc['active'] == true) { 
          emit(doc['email'], null); 
        }
      }"
      
  timestamps! #force writing of updated_at and created_at
  
  before_save :downcase_email
  before_save :generate_uri
  
  # validation
  validates_with_method :password, :method => :validate_passwords # use a special method for this, as we don't have couch properties to store the cleartext password
  validates_with_method :email, :method => :check_email_uniqueness
  validates_format :email, :as => :email_address # use the built-in email validator
  validates_present :name

  # authentication stuff....

  def validate_passwords
    #only check if new document, or password being changed.
    if self.new_document? || @entered_password || @confirm_password 
     
      if @entered_password.nil? || @entered_password.length < 4
        return [false, "Password is too short or is not specified"]
      end
      
      unless @entered_password == @confirm_password
        return [false, "Password doesn't match the confirmation"]
      end
      
    end
    return true
  end
  
  def check_email_uniqueness
    if self.new_document? && Account.by_email(:key => self.email).length > 0
      return [false, "A user has already been created with this email address"]
    end
    return true
  end
  
  def downcase_email
    self.email = email.downcase
  end
  
  def self.authenticate(email, entered_password)
    
    #notice that we don't care about the case of the email.    
    account = Account.by_active_email(:key => email.downcase).first 
    
    if account
      entered_password_hash = encrypted_password(entered_password, account.password_salt)
      unless account.password_hash == entered_password_hash
        account = nil
      end
    else
      account = nil
    end
    
    # return the authenticated account (will be nil if auth failed).
    return account
    
  end
  
  def password=(pass)
    @entered_password = pass
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_salt = salt
    self.password_hash = Account.encrypted_password(pass,salt)
  end
  
  def confirm_password=(pass)
    @confirm_password = pass
  end
  
  def password
    nil
  end
  
  def confirm_password
    nil
  end
  
  def generate_uri
	  # TODO: if a personal uri is not specified, generate the url for a public representation of the user on 
	  # the semjo or swirrl site?
	end
  
  private
  
  def self.encrypted_password(pass, salt)
    Digest::SHA256.hexdigest(pass + salt)
  end

end