class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles, force: true do |t|
      t.string :title
      t.integer :latest_revision
      t.datetime :latest_revision_datetime
      t.string :rating
      t.text :ores_data
      t.float :wp10
      t.float :average_views
      t.date :average_views_updated_at
      t.boolean :tweeted
      t.timestamp :tweeted_at
      t.boolean :redirect
      t.timestamps null: false
      t.integer :image_count
      t.string :first_image_url
      t.timestamp :failed_tweet_at
    end
  end
end
