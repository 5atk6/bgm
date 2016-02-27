class CreateBgms < ActiveRecord::Migration
  def change
    create_table :bgms do |t|
      t.integer :track_id
      t.integer :artist_id
      t.string  :track_name
      t.string  :artist_name
      t.integer  :count
      t.timestamp null: false
    end
  end
end
