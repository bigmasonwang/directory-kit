class Listing < ApplicationRecord
  include Statuses

  belongs_to :category
  belongs_to :user, default: -> { Current.user }

  has_one_attached :logo

  has_many :listing_tags, dependent: :destroy
  has_many :tags, through: :listing_tags

  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :description, presence: true

  validate :tags_limit

  normalizes :name, with: -> { _1.strip }
  normalizes :url, with: -> { _1.strip }

  private

  def tags_limit
    errors.add(:tags, "are limited to 5") if tags.size > 5
  end
end
