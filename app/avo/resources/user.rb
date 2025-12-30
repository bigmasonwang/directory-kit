class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :name, as: :text
    field :avatar_url, as: :text
    field :provider, as: :text
    field :uid, as: :text
  end
end
