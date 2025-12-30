class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.text :description, null: false
      t.string :status, null: false, default: "pending"
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :listings, :status
  end
end
