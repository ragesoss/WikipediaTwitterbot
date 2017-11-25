
# Run these commands to get started from scratch

class ArticleDatabase
  def self.create(bot_name)
    require 'sqlite3'
    require 'active_record'

    SQLite3::Database.new("#{bot_name}.sqlite3")
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                            database: "#{bot_name}.sqlite3")
    ActiveRecord::Migrator.migrate('db', 1)
  end
end
