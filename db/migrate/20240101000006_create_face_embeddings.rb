# frozen_string_literal: true

class CreateFaceEmbeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :face_embeddings do |t|
      t.references :profile, null: false, foreign_key: true
      t.text :external_face_id # Encrypted AWS Rekognition Face ID or mock ID
      t.text :face_data        # Encrypted face descriptor data
      t.string :status, default: "pending" # pending, enrolled, failed
      t.datetime :enrolled_at

      t.timestamps
    end

    add_index :face_embeddings, :status
  end
end
