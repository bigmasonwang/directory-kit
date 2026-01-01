require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:chatbot)
    @listing = listings(:digitalocean)
    @listing.tags << @tag
  end

  test "should get index" do
    get tags_url
    assert_response :success
    assert_select "a", text: /#{@tag.name}/
  end

  test "should get show" do
    get tag_url(slug: @tag.slug)
    assert_response :success
    assert_select "h1", @tag.name
  end

  test "show displays listings with tag" do
    get tag_url(slug: @tag.slug)
    assert_response :success
    assert_select ".card", count: 1
  end
end
