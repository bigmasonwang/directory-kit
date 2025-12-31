require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:digitalocean)
    @user = users(:one)
  end

  # Index tests
  test "should get index" do
    get listings_url
    assert_response :success
  end

  test "index shows published listings" do
    get listings_url
    assert_match @listing.name, response.body
  end

  test "index does not show pending listings" do
    get listings_url
    assert_no_match listings(:pending_tool).name, response.body
  end

  test "index filters by category" do
    get category_url(category: categories(:hosting).slug)
    assert_response :success
    assert_match @listing.name, response.body
  end

  # Show tests
  test "should get show for published listing" do
    get listing_url(id: @listing)
    assert_response :success
  end

  test "show displays listing details" do
    get listing_url(id: @listing)
    assert_match @listing.name, response.body
    assert_match @listing.description, response.body
  end

  test "show returns 404 for pending listing" do
    get listing_url(id: listings(:pending_tool))
    assert_response :not_found
  end

  # New tests
  test "new redirects unauthenticated users" do
    get new_listing_url
    assert_response :redirect
  end

  test "new renders form for authenticated users" do
    sign_in_as(@user)
    get new_listing_url
    assert_response :success
  end

  # Create tests
  test "create redirects unauthenticated users" do
    post listings_url, params: { listing: { name: "Test", url: "https://test.com", description: "Test desc", category_id: categories(:hosting).id } }
    assert_response :redirect
  end

  test "create saves listing for authenticated users" do
    sign_in_as(@user)

    assert_difference("Listing.count") do
      post listings_url, params: {
        listing: {
          name: "New Tool",
          url: "https://newtool.com",
          description: "A new tool",
          category_id: categories(:hosting).id
        }
      }
    end

    listing = Listing.last
    assert_equal "New Tool", listing.name
    assert_equal @user, listing.user
    assert listing.pending?
    assert_redirected_to root_path
  end

  test "create re-renders form with errors for invalid data" do
    sign_in_as(@user)

    assert_no_difference("Listing.count") do
      post listings_url, params: {
        listing: {
          name: "",
          url: "",
          description: "",
          category_id: nil
        }
      }
    end

    assert_response :unprocessable_entity
  end

  private

  def sign_in_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name, image: user.avatar_url }
    )
    get "/auth/google_oauth2/callback"
  end
end
