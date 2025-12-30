class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :avatar_url, as: :external_image
    field :name, as: :text
    field :email, as: :text
    field :admin, as: :boolean
    field :provider, as: :text
  end
end
