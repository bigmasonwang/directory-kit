class CreateListingTags < ActiveRecord::Migration[8.1]
  def change
    create_table :listing_tags do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :listing_tags, [:listing_id, :tag_id], unique: true
  end
end
