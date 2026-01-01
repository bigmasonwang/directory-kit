require "test_helper"

class ListingTagTest < ActiveSupport::TestCase
  test "belongs to listing" do
    listing_tag = listing_tags(:digitalocean_hosting)
    assert_respond_to listing_tag, :listing
    assert_instance_of Listing, listing_tag.listing
  end

  test "belongs to tag" do
    listing_tag = listing_tags(:digitalocean_hosting)
    assert_respond_to listing_tag, :tag
    assert_instance_of Tag, listing_tag.tag
  end

  test "cannot add same tag to same listing twice" do
    listing_tag = listing_tags(:digitalocean_hosting)
    duplicate = ListingTag.new(listing: listing_tag.listing, tag: listing_tag.tag)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:tag_id], "has already been added to this listing"
  end
end
