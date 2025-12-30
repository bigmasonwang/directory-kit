module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: -> { slug.blank? && name.present? }

    validates :slug, presence: true, uniqueness: true
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
