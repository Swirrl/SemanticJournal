Factory.define :account, :class => 'account' do |a|
  a.name "ric"
  a.display_name "Ric Roberts"
  a.email 'ric@swirrl.com'
  a.password 'password'
  a.confirm_password 'password'
end

Factory.define :account_no_pwd, :class => 'account' do |a|
  a.name "ric"
  a.display_name "Ric Roberts"
  a.email 'ric@swirrl.com'
end

Factory.define :account_no_name, :class => 'account' do |a|
  a.display_name "Ric Roberts"
  a.email 'ric@swirrl.com'
  a.password 'password'
  a.confirm_password 'password'
end
