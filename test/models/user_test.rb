require "test_helper"
require "ostruct"

class UserTest < ActiveSupport::TestCase
  test "validates presence of email" do
    user = User.new(provider: "google_oauth2", uid: "123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "validates presence of provider" do
    user = User.new(email: "test@example.com", uid: "123")
    assert_not user.valid?
    assert_includes user.errors[:provider], "can't be blank"
  end

  test "validates presence of uid" do
    user = User.new(email: "test@example.com", provider: "google_oauth2")
    assert_not user.valid?
    assert_includes user.errors[:uid], "can't be blank"
  end

  test "validates uniqueness of email" do
    existing = users(:one)
    user = User.new(email: existing.email, provider: "google_oauth2", uid: "newuid")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "validates uniqueness of uid scoped to provider" do
    existing = users(:one)
    user = User.new(email: "new@example.com", provider: existing.provider, uid: existing.uid)
    assert_not user.valid?
    assert_includes user.errors[:uid], "has already been taken"
  end

  test "find_or_create_from_omniauth creates new user" do
    auth = mock_omniauth(uid: "newuser123", email: "new@example.com", name: "New User")

    assert_difference "User.count", 1 do
      user = User.find_or_create_from_omniauth(auth)
      assert_equal "new@example.com", user.email
      assert_equal "New User", user.name
      assert_equal "google_oauth2", user.provider
      assert_equal "newuser123", user.uid
    end
  end

  test "find_or_create_from_omniauth finds existing user" do
    existing = users(:one)
    auth = mock_omniauth(uid: existing.uid, email: existing.email, name: existing.name)

    assert_no_difference "User.count" do
      user = User.find_or_create_from_omniauth(auth)
      assert_equal existing.id, user.id
    end
  end

  private

  def mock_omniauth(uid:, email:, name:, image: "https://example.com/avatar.jpg")
    OpenStruct.new(
      provider: "google_oauth2",
      uid: uid,
      info: OpenStruct.new(email: email, name: name, image: image)
    )
  end
end
