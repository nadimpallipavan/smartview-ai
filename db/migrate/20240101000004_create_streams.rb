# frozen_string_literal: true

class CreateStreams < ActiveRecord::Migration[7.1]
  def change
    create_table :streams do |t|
      t.string :name, null: false
      t.text :description
      t.string :hls_url, null: false
      t.string :category, default: "general"
      t.string :channel_number
      t.boolean :is_live, default: true
      t.boolean :is_active, default: true
      t.string :logo_url
      t.jsonb :schedule, default: {}
      t.integer :viewer_count, default: 0

      t.timestamps
    end

    add_index :streams, :category
    add_index :streams, :is_live
    add_index :streams, :is_active
  end
end
