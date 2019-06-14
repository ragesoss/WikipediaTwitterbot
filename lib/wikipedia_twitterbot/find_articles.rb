require_relative 'wiki'

class FindArticles
  ################
  # Entry points #
  ################

  def self.by_ids(ids)
    existing_ids = Article.all.pluck(:id)
    ids -= existing_ids
    page_data = get_pages(ids)
    article_data = page_data.select { |page| page['ns'] == 0 }
    article_data.select! { |page| existing_ids.exclude?(page['pageid']) }

    articles = []
    article_data.each do |article|
      revision = article['revisions'][0]
      articles << Article.new(id: article['pageid'],
                              title: article['title'],
                              latest_revision: revision['revid'],
                              latest_revision_datetime: revision['timestamp'])
    end
    articles
  end

  def self.at_random(count: 100, new_only: false)
    # As of June 2019, recently created articles have page ids under
    # 62_000_000.
    ids = Array.new(count) { Random.rand(70_000_000) }
    if new_only
      ids -= Article.all.pluck(:id)
    end
    by_ids(ids)
  end

  def self.by_title(title)
    existing = Article.find_by(title: title)
    return existing if existing.present?
    page_data = Wiki.query title_info_query(title)
    article_data = page_data.data['pages'].values.first
    article = Article.new(id: article_data['pageid'],
                          title: article_data['title'],
                          latest_revision: article_data['lastrevid'],
                          latest_revision_datetime: article_data['touched'])

    return article unless article_data['redirect']

    # If it's a redirect, return the redirect target instead.
    redirect_target = article.wikilinks.first
    return by_title(redirect_target)
  end

  ####################
  # Internal methods #
  ####################

  def self.title_revisions_query(title)
    { prop: 'revisions',
      titles: title,
      rvprop: 'userid|ids|timestamp' }
  end

  def self.title_info_query(title)
    { prop: 'info',
      titles: title }
  end

  def self.revisions_query(article_ids)
    { prop: 'revisions',
      pageids: article_ids,
      rvprop: 'userid|ids|timestamp' }
  end

  def self.get_pages(article_ids)
    pages = {}
    threads = article_ids.in_groups(10, false).each_with_index.map do |group_of_ids, i|
      Thread.new(i) do
        pages = {}
        group_of_ids.each_slice(50) do |fifty_ids|
          rev_query = revisions_query(fifty_ids)
          rev_response = Wiki.query rev_query
          pages.merge! rev_response.data['pages']
        end
      end
    end

    threads.each(&:join)
    pages.values
  end
end
