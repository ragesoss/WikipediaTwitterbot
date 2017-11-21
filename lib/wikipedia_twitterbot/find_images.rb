class FindImages
  def self.first(article)
    page_text = Wiki.get_page_content article.title
    page_text[/File:.{,60}\.jpg/]
  end
end
