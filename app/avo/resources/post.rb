class Avo::Resources::Post < Avo::BaseResource
  def fields
    field :id, as: :id
    field :title, as: :text
    field :body, as: :markdown
    field :slug, as: :text, readonly: true
    field :published_at, as: :date_time
  end
end
