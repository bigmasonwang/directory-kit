class Avo::Resources::Tag < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :slug, as: :text, readonly: true
    field :listings, as: :has_many
  end
end
