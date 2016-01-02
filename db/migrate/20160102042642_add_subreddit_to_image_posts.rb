class AddSubredditToImagePosts < ActiveRecord::Migration
  def change
    add_column :image_posts, :subreddit, :string
  end
end
