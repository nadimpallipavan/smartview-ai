# frozen_string_literal: true

class CreateRecommendations < ActiveRecord::Migration[7.1]
  def change
    create_table :recommendations do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :content, null: false, foreign_key: true
      t.float :score, default: 0.0
      t.string :reason

      t.timestamps
    end

    add_index :recommendations, [:profile_id, :score]
    add_index :recommendations, [:profile_id, :content_id], unique: true
  end
end
