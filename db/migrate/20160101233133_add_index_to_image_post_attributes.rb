class AddIndexToImagePostAttributes < ActiveRecord::Migration
  def change
    add_index :image_posts, :url, :unique => true
    add_index :image_posts, :permalink, :unique => true
    add_index :image_posts, :thumbnail, :unique => true
  end
end
