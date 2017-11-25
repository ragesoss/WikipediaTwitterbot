require 'active_record'
require 'activerecord-import'
require 'sqlite3'
require 'logger'
require_relative 'tweet'
require_relative 'twitter_client'
require_relative 'find_images'

class Article < ActiveRecord::Base
  class << self
    attr_reader :bot_name

    def connect_to_database(bot_name)
      @bot_name = bot_name
      ActiveRecord::Base.logger = Logger.new('debug.log')
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: "#{bot_name}.sqlite3",
        encoding: 'utf8'
      )
    end
  end

  serialize :ores_data, Hash
  #################
  # Class methods #
  #################

  def self.last_tweetable
    tweetable.last
  end

  def self.first_tweetable
    tweetable.first
  end

  def self.tweetable
    where(tweeted: nil, failed_tweet_at: nil)
  end

  ####################
  # Instance methods #
  ####################
  def tweet
    Tweet.new(tweet_text, filename: @image)
    self.tweeted = true
    save
    'tweeted'
  rescue StandardError => e
    self.failed_tweet_at = Time.now
    save
    raise e
  end

  def screenshot_path
    "screenshots/#{escaped_title}.png"
  end

  def commons_link(image)
    "https://commons.wikimedia.org/wiki/#{CGI.escape(image.tr(' ', '_'))}"
  end

  def escaped_title
    # CGI.escape will convert spaces to '+' which will break the URL
    CGI.escape(title.tr(' ', '_'))
  end

  def views
    average_views.to_i
  end

  def quality
    wp10.to_i
  end

  def url
    "https://en.wikipedia.org/wiki/#{escaped_title}"
  end

  def mobile_url
    "https://en.m.wikipedia.org/wiki/#{escaped_title}"
  end

  def edit_url
    # Includes the summary preload #FixmeBot, so that edits can be tracked:
    # http://tools.wmflabs.org/hashtags/search/wikiphotofight
    "https://en.wikipedia.org/wiki/#{escaped_title}?veaction=edit&summary=%23#{bot_name}"
  end

  def make_screenshot
    webshot = Webshot::Screenshot.instance
    webshot.capture mobile_url, "public/#{screenshot_path}",
                    width: 800, height: 800, allowed_status_codes: [404]
  end

  def hashtag
    TwitterClient.new.top_hashtag(title)
  end

  def bot_name
    self.class.bot_name
  end

  class NoImageError < StandardError; end
end
