class Avo::Resources::ListingTag < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :listing, as: :belongs_to
    field :tag, as: :belongs_to
  end
end
