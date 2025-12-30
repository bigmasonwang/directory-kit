class Avo::Resources::Category < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :slug, as: :text
    field :description, as: :textarea
    field :listings, as: :has_many
  end
end
