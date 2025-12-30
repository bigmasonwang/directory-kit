class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end
end
