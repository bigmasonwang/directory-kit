require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "validates presence of name" do
    tag = Tag.new(name: nil)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "generates slug from name" do
    tag = Tag.create!(name: "Image Generation")
    assert_equal "image-generation", tag.slug
  end

  test "validates uniqueness of slug" do
    # chatbot fixture already exists
    duplicate = Tag.new(name: "Chatbot 2", slug: "chatbot")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "normalizes name by stripping whitespace" do
    tag = Tag.new(name: "  Automation  ")
    assert_equal "Automation", tag.name
  end
end
