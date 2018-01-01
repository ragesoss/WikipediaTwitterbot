require 'twitter'

# Finds tweetable articles, tweets them
class Tweet
  attr_reader :result
  # Find an article to tweet and tweet it
  def self.anything
    # Randomly tweet either the earlier tweetable Article in the database
    # or the latest.
    # Wikipedia increments page ids over time, so the first ids are the oldest
    # articles and the last ids are the latest.
    article = if coin_flip
                Article.last_tweetable
              else
                Article.first_tweetable
              end
    article.tweet
    puts "Tweeted #{article.title}"
  end

  ###############
  # Twitter API #
  ###############
  def initialize(tweet, opts = {})
    if opts[:filename]
      filename = opts.delete(:filename)
      Wiki.save_commons_image filename
      @result = TwitterClient.new.client.update_with_media(tweet, File.new(filename), opts)
      File.delete filename
    else
      @result = TwitterClient.new.client.update(tweet, opts)
    end
  end

  ###########
  # Helpers #
  ###########

  def self.coin_flip
    [true, false][rand(2)]
  end
end
