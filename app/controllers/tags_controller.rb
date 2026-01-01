class TagsController < ApplicationController
  def index
    @tags = Tag.left_joins(:listings)
               .select("tags.*, COUNT(CASE WHEN listings.status = 'published' THEN 1 END) AS listings_count")
               .group(:id)
               .order(:name)
  end

  def show
    @tag = Tag.find_by!(slug: params[:slug])
    @listings = @tag.listings.visible
                    .includes(:category, :user, :tags, logo_attachment: :blob)
                    .order(created_at: :desc)
  end
end
