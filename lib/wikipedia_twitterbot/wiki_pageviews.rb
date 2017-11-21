# Fetches pageview data from the Wikimedia pageviews REST API
# Documentation: https://wikimedia.org/api/rest_v1/?doc#!/Pageviews_data/get_metrics_pageviews_per_article_project_access_agent_article_granularity_start_end
class WikiPageviews
  ################
  # Entry points #
  ################

  # Given an article title and a date, return the number of page views for every
  # day from that date until today.
  #
  # [title]  title of a Wikipedia page (including namespace, if applicable)
  # [date]   a specific date
  def self.views_for_article(title, opts = {})
    language = opts[:language] || 'en'
    start_date = opts[:start_date] || 1.month.ago
    end_date = opts[:end_date] || Time.zone.today
    url = query_url(title, start_date, end_date, language)
    data = api_get url
    return unless data
    data = JSON.parse data
    return unless data.include?('items')
    daily_view_data = data['items']
    views = {}
    daily_view_data.each do |day_data|
      date = day_data['timestamp'][0..7]
      views[date] = day_data['views']
    end
    views
  end

  def self.average_views_for_article(title, opts = {})
    language = opts[:language] || 'en'
    data = recent_views(title, language)
    # TODO: better handling of unexpected or empty responses, including logging
    return unless data
    data = JSON.parse data
    return unless data.include?('items')
    daily_view_data = data['items']
    days = daily_view_data.count
    total_views = 0
    daily_view_data.each do |day_data|
      total_views += day_data['views']
    end
    return if total_views == 0
    average_views = total_views.to_f / days
    average_views
  end

  ##################
  # Helper methods #
  ##################
  def self.recent_views(title, language)
    start_date = 50.days.ago
    end_date = 1.day.ago
    url = query_url(title, start_date, end_date, language)
    api_get url
  end

  def self.query_url(title, start_date, end_date, language)
    title = CGI.escape(title)
    base_url = 'https://wikimedia.org/api/rest_v1/metrics/pageviews/'
    configuration_params = "per-article/#{language}.wikipedia/all-access/user/"
    start_param = start_date.strftime('%Y%m%d')
    end_param = end_date.strftime('%Y%m%d')
    title_and_date_params = "#{title}/daily/#{start_param}00/#{end_param}00"
    url = base_url + configuration_params + title_and_date_params
    url
  end

  ###################
  # Private methods #
  ###################
  class << self
    private

    def api_get(url)
      tries ||= 3
      response = Net::HTTP.get(URI.parse(url))
      response
    rescue Errno::ETIMEDOUT
      retry unless tries.zero?
    rescue StandardError => e
      raise e
    end
  end
end
