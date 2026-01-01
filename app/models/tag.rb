class Tag < ApplicationRecord
  include Sluggable

  has_many :listing_tags, dependent: :destroy
  has_many :listings, through: :listing_tags

  validates :name, presence: true

  normalizes :name, with: -> { _1.strip }
end
