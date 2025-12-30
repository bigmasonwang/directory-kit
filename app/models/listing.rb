class Listing < ApplicationRecord
  include Statuses

  belongs_to :category
  belongs_to :user, default: -> { Current.user }

  has_one_attached :logo

  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :description, presence: true

  normalizes :name, with: -> { _1.strip }
  normalizes :url, with: -> { _1.strip }
end
