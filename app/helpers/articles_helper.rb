module ArticlesHelper
  
  def post_article_path(article)
    if article.new_document?
      articles_path
    else
      hash_for_article_path({:id => article.permalink})
    end
  end
  
  def full_article_url(article, protocol = "http")
    "#{protocol}://#{@blog.canonical_url}/articles/#{article.permalink}"
  end
  
  def pagination_links
    pagination_links_html = ""
    
    if @page !=1
		  pagination_links_html += '<span class="newer_articles">' + link_to( h("< newer articles"), {:page => @page-1}) + '</span>' 
		end
		
		if @total_articles > @per_page * @page
	    pagination_links_html += '<span class="older_articles">' + link_to( h("older articles >"), {:page => @page+1}) + '</span>'
	  end
	  
	  return pagination_links_html
  end
   
  # make an article tag with the name passed in (e.g. :div). The about parameter is only required if there are multiple articles on the page, in which case it should be the url of the article in question. 
  # If there's only one, it will default to the page's url. 
  def rdfa_article_tag(tag_name, html_options = {}, about = nil, &block)
    
    article_options = {"xmlns:dc" => "http://purl.org/dc/terms/", "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema#"}
    article_options.merge!({:about => about}) if about
    article_options.merge!(html_options)
    
    content_tag(tag_name, article_options, {}, &block) 
  end
  
  def rdfa_title_tag(tag_name, title_content)
    content_tag(tag_name, {"property" => "dc:title"}) do
      title_content
    end
  end
  
  def rdfa_author_tag(tag_name, personal_uri, display_name)
    content_tag(tag_name, {"rel" => "dc:creator", "resource" => personal_uri} ) do
      h(display_name)
    end
  end
  
  def rdfa_date_tag(tag_name, date, time_format = "%d %b %Y")
    content_tag(tag_name, {"property" => "dc:date", "datatype"=>"xsd:dateTime", "content" => date.xmlschema} ) do
      date.strftime(time_format)
    end
  end
end
