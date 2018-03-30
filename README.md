# WikipediaTwitterbot

Gem for creating Twitter bots related to Wikipedia

## Get Twitter API credentials

Create a twitter account for your bot and then register an app, and put the credentials in twitter.yml:

```
twitter_consumer_key: ohai
twitter_consumer_secret: kthxbai
twitter_access_token: isee
twitter_access_token_secret: whatyoudidthere
```

For more info, see https://github.com/sferik/twitter#configuration

## Set up a database

Use this gem to create an article database, via irb:

```ruby
require 'wikipedia_twitterbot'
ArticleDatabase.create 'your_bot_name'
```

## Write your bot code

Now you can write a bot. Here's what a basic one might look like:

```ruby
require 'wikipedia_twitterbot'
Article.connect_to_database 'braggingvandalbot'

class TrivialWikipediaBot
  def self.tweet(article)
    tweet_text = "#{article.title} is here: #{article.url}"
    article.tweet tweet_text
  end

  # adds random articles to the database matching the given criteria
  def self.find_articles
    options = {
      max_w10: 30,
      min_views: 300
    }
    Article.import_at_random(options)
  end
end
```

`Article` provides both class methods for fetching and importing Wikipedia articles and metadata, and instance methods for supplying info about a particular article that you can use in tweets. See `article.rb` for more details.

Make your bot run by configuring cron jobs to import articles and tweet tweets about them.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the WikipediaTwitterbot project’s codebase and issue trackeris expected to follow the [code of conduct](https://github.com/ragesoss/WikipediaTwitterbot/blob/master/CODE_OF_CONDUCT.md).
