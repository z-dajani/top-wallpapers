class AddAttachmentThumbImgToImagePosts < ActiveRecord::Migration
  def self.up
    change_table :image_posts do |t|
      t.attachment :thumb_img
    end
  end

  def self.down
    remove_attachment :image_posts, :thumb_img
  end
end
