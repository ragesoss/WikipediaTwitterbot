
# Run these commands to get started from scratch

require 'sqlite3'
require 'active_record'

SQLite3::Database.new('braggingvandalbot.sqlite3')
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'braggingvandalbot.sqlite3')
ActiveRecord::Migrator.migrate('db', 1)
