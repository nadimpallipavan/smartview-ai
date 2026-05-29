# frozen_string_literal: true

class CreateViewingHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :viewing_histories do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :content, null: false, foreign_key: true
      t.datetime :watched_at, null: false
      t.float :progress, default: 0.0 # 0.0 to 1.0
      t.integer :watch_duration_seconds, default: 0
      t.boolean :completed, default: false

      t.timestamps
    end

    add_index :viewing_histories, [:profile_id, :content_id]
    add_index :viewing_histories, :watched_at
  end
end
