class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :bgm_id
      t.float  :x
      t.float  :y
      t.integer :user_id
      t.timestamp null: false
    end
  end
end
