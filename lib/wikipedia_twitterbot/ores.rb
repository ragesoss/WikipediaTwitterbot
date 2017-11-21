#= Imports revision scoring data from ores.wmflabs.org
class Ores
  ################
  # Entry points #
  ################
  def self.select_by_image_count(articles, image_count: 1)
    @ores = new
    articles.each do |article|
      article.ores_data = @ores.get_revision_data(article.latest_revision)
      puts article.ores_data.dig('scores', 'enwiki', 'wp10', 'features',
                            article.latest_revision.to_s,
                            'feature.enwiki.revision.image_links')
    end
    selected_articles = articles.select do |article|
      article.ores_data.dig('scores', 'enwiki', 'wp10', 'features',
                            article.latest_revision.to_s,
                            'feature.enwiki.revision.image_links') == image_count
    end
    selected_articles
  end

  def initialize
    @project_code = 'enwiki'
  end

  def get_revision_data(rev_id)
    # TODO: i18n
    response = ores_server.get query_url(rev_id)
    ores_data = JSON.parse(response.body)
    ores_data
  rescue StandardError => error
    raise error unless TYPICAL_ERRORS.include?(error.class)
    return {}
  end

  TYPICAL_ERRORS = [
    Errno::ETIMEDOUT,
    Net::ReadTimeout,
    Errno::ECONNREFUSED,
    JSON::ParserError,
    Errno::EHOSTUNREACH,
    Faraday::ConnectionFailed,
    Faraday::TimeoutError
  ].freeze

  class InvalidProjectError < StandardError
  end

  private

  def query_url(rev_id)
    base_url = "/v2/scores/#{@project_code}/wp10/"
    url = base_url + rev_id.to_s + '/?features'
    url = URI.encode url
    url
  end

  def ores_server
    conn = Faraday.new(url: 'https://ores.wikimedia.org')
    conn.headers['User-Agent'] = '@WikiPhotoFight by ragesoss'
    conn
  end
end
