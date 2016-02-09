class CreateRefreshInstances < ActiveRecord::Migration
  def change
    create_table :refresh_instances do |t|

      t.timestamps null: false
    end
  end
end
