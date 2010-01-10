xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    
    # TODO: make the title and the description configurable in the app?
    xml.title @blog.name
    xml.description "Articles from #{@blog.canonical_url}"
    xml.link "http://" + @blog.canonical_url

    for article in @articles
      xml.item do
        xml.title article.title
        xml.description((article.raw?) ? article.content : textilize(article.content))
        xml.pubDate article.published_at.to_s(:rfc822)
        xml.link article_url({:id => article.permalink})
        # guid is used to determine if the item is new, so append the date - doesn't have to be a valid url
        xml.guid article_url({:id => article.permalink}) + "?updated_at=" + article.updated_at.strftime("%Y-%m-%dT%H:%M:%S")
      end
    end
  end
end
