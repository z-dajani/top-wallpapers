class AddWidthAndHeightToImagePosts < ActiveRecord::Migration
  def change
    add_column :image_posts, :width, :integer
    add_column :image_posts, :height, :integer
  end
end
