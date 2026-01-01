require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = posts(:published_post)
    @draft = posts(:draft_post)
    @scheduled = posts(:scheduled_post)
  end

  test "index returns success" do
    get posts_url
    assert_response :success
  end

  test "index shows published posts" do
    get posts_url
    assert_match @published.title, response.body
  end

  test "index does not show draft posts" do
    get posts_url
    assert_no_match @draft.title, response.body
  end

  test "index does not show scheduled posts" do
    get posts_url
    assert_no_match @scheduled.title, response.body
  end

  test "show returns success for published post" do
    get post_url(slug: @published.slug)
    assert_response :success
  end

  test "show displays post content" do
    get post_url(slug: @published.slug)
    assert_match @published.title, response.body
  end

  test "show returns 404 for draft post" do
    get post_url(slug: @draft.slug)
    assert_response :not_found
  end

  test "show returns 404 for scheduled post" do
    get post_url(slug: @scheduled.slug)
    assert_response :not_found
  end

  test "show returns 404 for nonexistent slug" do
    get post_url(slug: "nonexistent")
    assert_response :not_found
  end
end
