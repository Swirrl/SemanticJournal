class ArticlesController < ApplicationController
  
  before_filter :get_most_recent_article, :only => [:home, :show, :feed]   
  before_filter :get_article_by_permalink, :only => [:show, :edit, :update, :destroy, :preview]

  # PUBLIC ACTIONS
  
  skip_before_filter :get_session_user, :only => [:show, :home, :feed]
  
  # show an article. Don't need to be logged in, but don't allow viewing of unpublished articles.
  def show
    fresh_when(:last_modified => @article.updated_at, :public => true)
    unless @article.is_published?
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return false 
    end
  end
  
  def home 
    if stale?(:last_modified => @most_recently_updated_article.updated_at, :public => true)
      @page = params[:page].to_i || 1
      @page = 1 if @page < 1
      @per_page = 8
      @articles = Article.get_paginated_articles({:page => @page, :per_page => @per_page})
      @total_articles = Article.by_published_at(:reduce => true)["rows"][0]["value"]
    end
  end  
  
  def feed
    if stale?(:last_modified => @most_recently_updated_article.updated_at, :public => true) 
      # At the moment, only provide the 10 latest articles in the feed.
      @articles = Article.by_published_at(:limit => 10)
      render :layout => false
    end
  end
  
  #LOGGED-IN ACTIONS:
  
  def preview
    render :template => "articles/show"
  end
  
  def index
    @articles = Article.by_created_at
  end
  
  def new
    @article = Article.new
  end

  def edit
  end
  
  def update
    
    assign_article_params
    
    if @article.save
      redirect_to edit_article_path(@article.permalink)
    else
      # TODO
    end
    
    # TODO: deal with 409 locking errors from couch. 
  end
  
  def create
    # don't use mass assignment, 
    # as (ATM) couchrest doesn't support protected attrs (as anything can be assigned to the doc hash).
    @article = Article.new
    
    assign_article_params
    
    if @article.save
      $last_modified = nil
      redirect_to edit_article_path(@article.permalink)
    else
      # TODO
    end
    
  end
  
  def destroy
    # just hard-delete. 
    @article.destroy
    
    redirect_to :action => 'index'
  end
  
  private
  
    def get_most_recent_article
      @most_recently_updated_article = Article.by_published_at(:limit => 1).first  
    end
  
    def assign_article_params
      article_params = params["article"]
      @article.title = article_params["title"]
      @article.content = article_params["content"]
      @article.set_published(article_params["is_published"]=="true", session[:account])
    end
  
    def get_article_by_permalink
      @article = Article.by_permalink(:key => params[:id]).first
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 and return false unless @article
    end
  
end