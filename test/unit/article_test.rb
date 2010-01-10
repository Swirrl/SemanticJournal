require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase

  def setup
    setup_factories
  end
  
  def test_creating_permalink
    a = Factory.create(:permalink_less_article)        
    assert_equal "this-is-a-title-123", a.permalink
    
    # check we have timestamps
    assert_not_nil a.updated_at
    assert_not_nil a.created_at
  end
  
  def test_creating_permalink_unusual_characters
    a = Factory.create(:article_with_unusual_chars)
    assert_equal "this-is-a-title-456", a.permalink
  end
  
  def test_duplicate_permalink
    a = Factory.create(:permalink_less_article)        
    a2 = Factory.create(:permalink_less_article)        
    assert_equal "this-is-a-title-123-1", a2.permalink
  end
  
  def test_no_title
    a = Factory.create(:permalink_less_article) 
    a.title = nil       
    assert !a.save    
    assert_equal "Title must not be blank", a.errors[:title].first
  end
  
  def test_title_too_short
    a = Article.new
    a.title = "ab"     
    assert !a.save    
    assert_equal "Title must be between 3 and 255 characters long", a.errors[:title].first
  end
     
  def test_publishing
    a = Factory.build(:unpublished_article)
    a.set_published(true, "ric")
    
    # check that it worked.
    assert_equal "ric", a.published_by
    assert_not_nil a.published_at
  end
  
  def test_republishing
    a = Factory.build(:article)
    a.set_published(true, "ric")
    published_time = a.published_at
    
    # check that it didn't change anything
    assert_equal "ric", a.published_by
    assert_equal published_time, a.published_at
  end
  
  
end
