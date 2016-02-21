class CreateBgms < ActiveRecord::Migration
  def change
    create_table :bgms do |t|
      t.integer :track_id
      t.timestamp null: false
    end
  end
end
