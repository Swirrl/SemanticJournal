require File.dirname(__FILE__) + '/../test_helper'

class BlogTest < ActiveSupport::TestCase

  def setup
    setup_factories
  end
    
  def test_canonical_url_hosts
    b = Factory.create(:blog)
    # should be the first item in the hosts array.
    assert_equal "test.host", b.canonical_url
  end

end