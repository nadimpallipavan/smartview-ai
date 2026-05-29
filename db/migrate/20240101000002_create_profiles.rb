# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :avatar_color, default: "#6366f1"
      t.boolean :is_kids, default: false, null: false
      t.boolean :is_default, default: false, null: false
      t.text :preferences # JSON serialized

      t.timestamps
    end

    add_index :profiles, [:user_id, :name], unique: true
  end
end
