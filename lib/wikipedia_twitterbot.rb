require "wikipedia_twitterbot/version"

module WikipediaTwitterbot
  require_relative 'wikipedia_twitterbot/article'
  require_relative 'wikipedia_twitterbot/wiki'
  require_relative 'wikipedia_twitterbot/wiki_pageviews'
  require_relative 'wikipedia_twitterbot/ores'
  require_relative 'wikipedia_twitterbot/twitter_client'
  require_relative 'wikipedia_twitterbot/find_articles'
  require_relative 'wikipedia_twitterbot/find_images'
  require_relative 'wikipedia_twitterbot/high_pageviews'
  require_relative 'wikipedia_twitterbot/category_filter'
  require_relative 'wikipedia_twitterbot/discard_redirects'
  require_relative 'wikipedia_twitterbot/tweet'
  require_relative 'wikipedia_twitterbot/db/bootstrap'
end
