class SessionsController < ApplicationController

  skip_before_filter :get_session_user 
  
  filter_parameter_logging :password, :confirm_password

  # create a new session - i.e. log in.
  def create
    
    authenticated_account = Account.authenticate( params[:email], params[:password] )
    
    if (authenticated_account)
      
      # successfully authenticated - populate the session variable and then send them on their merry way.
      session[:account] = authenticated_account.name
      
      # TODO: redirect to some kind of dashboard.
      redirect_to :controller => "articles", :action => "index"
      
    else
      
      flash[:notice] = 'Invalid login details'
      redirect_to :action => 'new'
      
    end
    
  end

end