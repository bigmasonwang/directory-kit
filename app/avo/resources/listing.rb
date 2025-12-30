class Avo::Resources::Listing < Avo::BaseResource
  self.includes = [ :category, :user ]

  def fields
    field :id, as: :id
    field :logo, as: :file
    field :name, as: :text
    field :url, as: :text, as_html: true, format_using: -> { link_to(value, value, target: "_blank") if value.present? }
    field :description, as: :textarea
    field :status, as: :badge, options: { pending: :warning, published: :success, rejected: :danger }
    field :category, as: :belongs_to
    field :user, as: :belongs_to
  end
end
