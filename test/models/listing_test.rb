require "test_helper"

class ListingTest < ActiveSupport::TestCase
  test "validates presence of name" do
    listing = Listing.new(name: nil)
    assert_not listing.valid?
    assert_includes listing.errors[:name], "can't be blank"
  end

  test "validates presence of url" do
    listing = Listing.new(url: nil)
    assert_not listing.valid?
    assert_includes listing.errors[:url], "can't be blank"
  end

  test "validates url format" do
    listing = Listing.new(url: "not-a-url")
    assert_not listing.valid?
    assert_includes listing.errors[:url], "is invalid"
  end

  test "accepts valid http url" do
    listing = listings(:digitalocean)
    listing.url = "http://example.com"
    assert listing.valid?
  end

  test "accepts valid https url" do
    listing = listings(:digitalocean)
    listing.url = "https://example.com"
    assert listing.valid?
  end

  test "validates presence of description" do
    listing = Listing.new(description: nil)
    assert_not listing.valid?
    assert_includes listing.errors[:description], "can't be blank"
  end

  test "has pending status by default" do
    listing = Listing.new
    assert_equal "pending", listing.status
  end

  test "visible scope returns only published listings" do
    assert_includes Listing.visible, listings(:digitalocean)
    assert_not_includes Listing.visible, listings(:pending_tool)
  end

  test "publish! changes status to published" do
    listing = listings(:pending_tool)
    listing.publish!
    assert listing.published?
  end

  test "reject! changes status to rejected" do
    listing = listings(:pending_tool)
    listing.reject!
    assert listing.rejected?
  end

  test "normalizes name by stripping whitespace" do
    listing = Listing.new(name: "  DigitalOcean  ")
    assert_equal "DigitalOcean", listing.name
  end

  test "normalizes url by stripping whitespace" do
    listing = Listing.new(url: "  https://example.com  ")
    assert_equal "https://example.com", listing.url
  end

  test "belongs to category" do
    listing = listings(:digitalocean)
    assert_equal categories(:hosting), listing.category
  end

  test "belongs to user" do
    listing = listings(:digitalocean)
    assert_equal users(:one), listing.user
  end

  test "can have many tags" do
    listing = listings(:digitalocean)
    assert_respond_to listing, :tags
  end

  test "validates maximum of 5 tags" do
    listing = listings(:digitalocean)
    6.times { |i| listing.tags << Tag.create!(name: "Tag #{i}") }
    assert_not listing.valid?
    assert_includes listing.errors[:tags], "are limited to 5"
  end
end
