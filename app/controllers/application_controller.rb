# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  before_filter :set_current_account, :get_session_user
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  private
    
    def set_current_account
     
      Thread.current[:env] = Rails.env.to_sym # set the current env on the thread
            
      # first, try to match the whole host to a blog's host in the db
      @blog = Blog.by_hosts(:key => request.host, :limit => 1, :reduce=>false).first 
      
      # failing that, use the subdomain.
      @blog = Blog.by_name(:key => request.subdomains.first).first unless @blog
      
      # redirect to the first item in the hosts array (the 'canonical domain' for this blog.)
      # this ensures that things like disqus work fine, and don't end up with multiple discussion threads:
      # (one for each url.)
      if @blog && @blog.hosts && @blog.hosts[0] != request.host
        parts = []
        parts << request.protocol
        parts << @blog.hosts[0]
        parts << request.path
        redirect_to parts.join
      end
       
      # TODO: change this so that it redirects to our promotional site if account doesn't exist.
      unless @blog
        render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 
        return false #  quit filter chain
      end
      
      svr = CouchRest::Server.new(APP_CONFIG['couch_db_location'])
      couch_db = CouchRest::Database.new(svr, @blog.name)

      Thread.current[:blog_db] = couch_db
      
      # For now, this is inside the project folder, but could be somewhere else, and symlinked in.
      # Could also use a sharding approach if we get lots of users!.
      prepend_view_path ["#{RAILS_ROOT}/app/views/themes/custom/#{@blog.name}/"]
    
    end

    def get_session_user
    
      logger.debug session[:account]
    
      if session[:account]
        # if we have an email in the sesssion, look up the blog user database to see if they're a user for this blog
        @session_blog_user = BlogUser.by_account(:key => session[:account]).first
        @session_account = Account.get(@session_blog_user.account) if @session_blog_user
        @logged_in = true
      else
        # if there's nothing in the session, make sure the session user variable is nil'd out
        @session_blog_user = nil
        @session_account = nil
        @logged_in = false
      end
    
      # if we don't have a logged in user, redirect to the log in screen
      redirect_to :action => 'new', :controller => 'sessions' unless @session_account
        
    end
    
    
end
