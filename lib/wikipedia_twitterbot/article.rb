require 'active_record'
require 'activerecord-import'
require 'sqlite3'
require 'logger'
require 'fileutils'
require_relative 'tweet'
require_relative 'twitter_client'
require_relative 'find_images'
require_relative 'article_text_cleaner'

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

  def self.import_at_random(opts)
    import fetch_at_random(opts)
  end

  DEFAULT_OPTS = {
    count: 10_000,
    discard_redirects: true,
    min_views: 0,
    max_wp10: nil,
    discard_dabs: true
  }.freeze

  def self.fetch_at_random(opts)
    options = DEFAULT_OPTS.merge opts

    articles = FindArticles.at_random(count: options[:count])
    puts "#{articles.count} mainspace articles found"

    if options[:discard_redirects]
      articles = DiscardRedirects.from(articles)
      puts "#{articles.count} are not redirects"
    end

    if options[:min_views].positive?
      articles = HighPageviews.from_among(articles, min_views: options[:min_views])
      puts "#{articles.count} of those have high page views"
    end

    if options[:max_wp10]
      articles = Ores.discard_high_revision_scores(articles, max_wp10: options[:max_wp10])
      puts "#{articles.count} of those have low revision scores"
    end

    if options[:discard_dabs]
      articles = CategoryFilter.discard_disambiguation_pages(articles)
      puts "#{articles.count} of those are not disambiguation pages"
    end

    if articles.count > 0
      puts "#{articles.count} tweetable prospect(s) found!"
    else
      puts 'no tweetable articles found'
    end

    articles
  end

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
  def tweet(tweet_text, opts = {})
    @tweet_result = Tweet.new(tweet_text, opts).result
    self.tweeted = true
    save
    pp 'tweeted'
    @tweet_result
  rescue StandardError => e
    self.failed_tweet_at = Time.now
    save
    raise e
  end

  def screenshot_path
    FileUtils.mkdir_p('screenshots') unless File.directory?('screenshots')
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

  def dirp
    pp RASTERIZE_PATH
  end

  RASTERIZE_PATH = "#{__dir__}/rasterize.js".freeze
  def make_screenshot
    # Use rasterize script to make a screenshot
    %x[phantomjs #{RASTERIZE_PATH} #{mobile_url} #{screenshot_path} 1000px*1000px]
    # Trim any extra blank space, which may or may not be present.
    %x[convert #{screenshot_path} -trim #{screenshot_path}]
  end

  def hashtag
    TwitterClient.new.top_hashtag(title)
  end

  def bot_name
    self.class.bot_name
  end

  def wikilinks
    return @links if @links.present?
    query = { prop: 'links', titles: title, plnamespace: '0', pllimit: 500 }
    response = Wiki.query query
    @links = response.data['pages'].values.first['links'].map { |link| link['title'] }
    @links
  end

  def page_text
    @page_text ||= Wiki.get_page_content title
  end

  def plaintext
    @plaintext = ArticleTextCleaner.convert(page_text)
  end

  def sentence_with(text)
    # TODO: Remove the plaintext footnote remnants
    plaintext[/[^.?!\n]*#{Regexp.quote text}[^.?!]*[.?!]/i]
  end

  class NoImageError < StandardError; end
end
