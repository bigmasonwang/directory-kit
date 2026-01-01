require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "validates presence of title" do
    post = Post.new(title: nil, body: "Content")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "validates presence of body" do
    post = Post.new(title: "Title", body: nil)
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "generates slug from title" do
    post = Post.create!(title: "My First Post", body: "Content")
    assert_equal "my-first-post", post.slug
  end

  test "validates uniqueness of slug" do
    duplicate = Post.new(title: "First Blog Post 2", slug: "first-blog-post", body: "Content")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "published scope returns only published posts" do
    published = posts(:published_post)
    draft = posts(:draft_post)
    scheduled = posts(:scheduled_post)

    results = Post.published

    assert_includes results, published
    assert_not_includes results, draft
    assert_not_includes results, scheduled
  end

  test "draft? returns true when published_at is nil" do
    assert posts(:draft_post).draft?
    assert_not posts(:published_post).draft?
  end

  test "scheduled? returns true when published_at is in the future" do
    assert posts(:scheduled_post).scheduled?
    assert_not posts(:published_post).scheduled?
  end

  test "published? returns true when published_at is in the past" do
    assert posts(:published_post).published?
    assert_not posts(:draft_post).published?
    assert_not posts(:scheduled_post).published?
  end
end
