Factory.define :blog do |b|
  b.name "semjo_test_blog"
  b.hosts ["test.host", "www.test.com"]
end

Factory.define :blog_no_hosts,  :class => 'blog' do |b|
  b.name "semjo_test_blog_2"
end