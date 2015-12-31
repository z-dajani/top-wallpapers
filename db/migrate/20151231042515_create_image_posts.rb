class CreateImagePosts < ActiveRecord::Migration
  def change
    create_table :image_posts do |t|
      t.string :title
      t.string :url
      t.string :permalink
      t.string :thumbnail
      t.integer :score

      t.timestamps null: false
    end
  end
end
