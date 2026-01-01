class ListingTag < ApplicationRecord
  belongs_to :listing
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :listing_id, message: "has already been added to this listing" }
end
