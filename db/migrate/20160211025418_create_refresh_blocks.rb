class CreateRefreshBlocks < ActiveRecord::Migration
  def change
    create_table :refresh_blocks do |t|

      t.timestamps null: false
    end
  end
end
