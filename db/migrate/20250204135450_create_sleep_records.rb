# frozen_string_literal: true

class CreateSleepRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, foreign_key: true, index: true
      t.datetime :wake_time, null: false
      t.datetime :sleep_time, null: false
      t.integer :duration, null: false
      t.timestamps
    end
  end
end
