class Category < ApplicationRecord
  include Sluggable

  has_many :listings, dependent: :destroy

  validates :name, presence: true

  normalizes :name, with: -> { _1.strip }
end
