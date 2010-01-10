ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  
  map.connect '', :controller => 'articles', :action => 'home'  
  map.connect '/', :controller => 'articles', :action => 'home'  
  map.connect '/feed.:format', :controller => 'articles', :action => 'feed'  
  
  map.resources :articles, :member => {:preview => :get}
  map.resources :sessions
  
  #alias for the articles index. TODO: once we have some kind of control panel, change to that.
  map.connect '/admin', :controller => 'articles', :action => 'index' 
  
end
