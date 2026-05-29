# frozen_string_literal: true

class CreateContents < ActiveRecord::Migration[7.1]
  def change
    create_table :contents do |t|
      t.string :title, null: false
      t.text :description
      t.string :genre, null: false
      t.string :content_type, null: false, default: "movie" # movie, series, documentary, live
      t.string :hls_url
      t.string :trailer_url
      t.integer :duration # in minutes
      t.float :rating, default: 0.0
      t.integer :year
      t.string :maturity_rating, default: "TV-14"
      t.string :language, default: "English"
      t.string :director
      t.string :cast, array: true, default: []
      t.string :tags, array: true, default: []
      t.boolean :featured, default: false
      t.boolean :published, default: true
      t.integer :view_count, default: 0

      t.timestamps
    end

    add_index :contents, :genre
    add_index :contents, :content_type
    add_index :contents, :featured
    add_index :contents, :published
    add_index :contents, :tags, using: :gin
  end
end
