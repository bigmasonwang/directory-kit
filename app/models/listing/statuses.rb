module Listing::Statuses
  extend ActiveSupport::Concern

  included do
    enum :status, %w[pending published rejected].index_by(&:itself)

    scope :visible, -> { published }
  end

  def publish!
    update!(status: :published)
  end

  def reject!
    update!(status: :rejected)
  end
end
