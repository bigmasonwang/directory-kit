require "test_helper"

class AvoAuthenticationTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated users from avo" do
    get "/avo"
    assert_response :redirect
    assert_equal "/", response.location.gsub("http://www.example.com", "")
  end

  test "redirects non-admin users from avo" do
    user = users(:one)
    assert_not user.admin?

    # Sign in as non-admin
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { email: user.email, name: user.name, image: user.avatar_url }
    )
    get "/auth/google_oauth2/callback"

    get "/avo"
    assert_response :redirect
    assert_equal "/", response.location.gsub("http://www.example.com", "")
  end

  test "allows admin users to access avo" do
    # Create admin user via OAuth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "admin_test_123",
      info: { email: "admin@example.com", name: "Admin User", image: "https://example.com/avatar.jpg" }
    )
    get "/auth/google_oauth2/callback"

    user = User.find_by(email: "admin@example.com")
    user.update!(admin: true)

    get "/avo"
    # Avo redirects to default resource, so follow it
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
