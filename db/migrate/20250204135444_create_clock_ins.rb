# frozen_string_literal: true

class CreateClockIns < ActiveRecord::Migration[5.0]
  def change
    create_table :clock_ins do |t|
      t.references :user, foreign_key: true, index: true
      t.string :clock_in_type, null: false
      t.timestamps
    end
  end
end
