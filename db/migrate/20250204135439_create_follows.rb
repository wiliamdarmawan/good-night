# frozen_string_literal: true

class CreateFollows < ActiveRecord::Migration[5.0]
  def change
    create_table :follows do |t|
      t.references :following, foreign_key: { to_table: :users }
      t.references :follower, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :follows, %i[following_id follower_id], unique: true
  end
end
