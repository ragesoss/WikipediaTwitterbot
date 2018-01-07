require 'pandoc-ruby'

class ArticleTextCleaner
  def self.convert(page_text)
    new(page_text).convert
  end

  def initialize(page_text)
    @page_text = page_text
  end

  def convert
    @output = PandocRuby.new(@page_text, from: :mediawiki, to: :plain).convert
    remove_refs
    replace_single_linebreaks
    @output
  end

  # Refs in up in plaintext as: [12]
  def remove_refs
    @output.gsub!(/\[\d+\]/, '')
  end

  # Linebreaks just for line wrapping appear where spaces should be.
  # Double line breaks happen between paragraphs; leave those in place.
  def replace_single_linebreaks
    @output.gsub!(/(?<!\n)\n(?!\n)/, ' ')
  end
end
