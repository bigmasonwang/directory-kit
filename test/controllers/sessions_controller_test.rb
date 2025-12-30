require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "create signs in user via oauth callback" do
    auth_hash = {
      "provider" => "google_oauth2",
      "uid" => "123456",
      "info" => {
        "email" => "oauth@example.com",
        "name" => "OAuth User",
        "image" => "https://example.com/avatar.jpg"
      }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    assert_difference "User.count", 1 do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to root_path
    assert_equal "Signed in!", flash[:notice]

    user = User.find_by(email: "oauth@example.com")
    assert_equal user.id, session[:user_id]
  end

  test "create finds existing user" do
    existing = users(:one)

    auth_hash = {
      "provider" => existing.provider,
      "uid" => existing.uid,
      "info" => {
        "email" => existing.email,
        "name" => existing.name,
        "image" => existing.avatar_url
      }
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)

    assert_no_difference "User.count" do
      get "/auth/google_oauth2/callback"
    end

    assert_redirected_to root_path
    assert_equal existing.id, session[:user_id]
  end

  test "destroy signs out user" do
    # Sign in first via OAuth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "signout_test_123",
      info: { email: "signout@example.com", name: "Sign Out User", image: "https://example.com/avatar.jpg" }
    )
    get "/auth/google_oauth2/callback"

    user = User.find_by(email: "signout@example.com")
    assert_equal user.id, session[:user_id]

    delete "/logout"

    assert_redirected_to root_path
    assert_equal "Signed out!", flash[:notice]
    assert_nil session[:user_id]
  end

  test "failure redirects with error message" do
    get "/auth/failure", params: { message: "access_denied" }

    assert_redirected_to root_path
    assert_equal "Authentication failed: access_denied", flash[:alert]
  end
end
