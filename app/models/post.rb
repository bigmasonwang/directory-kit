class Post < ApplicationRecord
  include Sluggable

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where("published_at <= ?", Time.current) }

  def name
    title
  end

  def draft?
    published_at.nil?
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end

  def published?
    published_at.present? && published_at <= Time.current
  end
end
