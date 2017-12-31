class FindImages
  def self.first(article)
    article.page_text[/File:.{,60}\.jpg/]
  end
end
