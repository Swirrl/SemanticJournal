require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActiveSupport::TestCase

  def setup
    setup_factories
  end
  
  def test_account_save_success  
    a = Factory.build(:account)     
    assert a.save
  end
     
  def test_duplicate_email
    a = Factory.create(:account)
    a2 = Factory.build(:account)
    assert !a2.save
    assert_equal "A user has already been created with this email address", a2.errors.full_messages[0]
  end
   
  def test_no_password
    a = Factory.build(:account_no_pwd)  
    assert !a.save
    assert_equal "Password is too short or is not specified", a.errors.full_messages[0]
  end
   
  def test_password_confirm
    a = Factory.build(:account)  
    a.confirm_password = "passwo" #different to the 1st one.
    assert !a.save
    assert_equal "Password doesn't match the confirmation", a.errors.full_messages[0]
  end
   
  def test_invalid_email
    a = Factory.build(:account)  
    a.email = 'ric_swirrl.com'
    assert !a.save
    assert_equal "Email has an invalid format", a.errors.full_messages[0]
  end
   
  def test_no_name
    a = Factory.build(:account_no_name)  
    assert !a.save
    assert_equal "Name must not be blank", a.errors.full_messages[0]
  end
    
  def test_authenticate_success
    a = Factory.create(:account)       
    authed_acc = Account.authenticate( a.email.upcase, "password" ) # notice that case doesn't matter for the email
    assert authed_acc # should just not be nil
  end
    
  def test_authenticate_fail
    a = Factory.create(:account)       
    authed_acc = Account.authenticate( a.email.upcase, "passwo" ) # notice that case doesn't matter for the email   
    assert_nil authed_acc # should be nil
  end
    
  def test_authenticate_no_credentials
    authed_acc = Account.authenticate( "", "" )   
    assert_nil authed_acc # should be nil
  end
    
  def test_save_existing_user
    a = Factory.create(:account)       
    a = Account.by_active_email(:key => a.email).first
    # change the name
    a.name = 'Richard'
    # should work without specifying pwd.
    assert a.save
  end
    
end