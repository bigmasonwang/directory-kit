require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "validates presence of name" do
    category = Category.new(name: nil)
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "generates slug from name" do
    category = Category.create!(name: "New Category")
    assert_equal "new-category", category.slug
  end

  test "validates uniqueness of slug" do
    # hosting fixture already exists
    duplicate = Category.new(name: "Hosting 2", slug: "hosting")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "normalizes name by stripping whitespace" do
    category = Category.new(name: "  Dev Tools  ")
    assert_equal "Dev Tools", category.name
  end

  test "has many listings" do
    category = categories(:hosting)
    assert_respond_to category, :listings
  end
end
