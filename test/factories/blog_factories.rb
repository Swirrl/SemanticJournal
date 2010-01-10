Factory.define :blog do |b|
  b.name "test"
  b.hosts ["test.com", "www.test.com"]
end

Factory.define :blog_no_hosts,  :class => 'blog' do |b|
  b.name "test2"
end