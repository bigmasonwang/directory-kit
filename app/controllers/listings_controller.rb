class ListingsController < ApplicationController
  before_action :require_authentication, only: %i[new create]
  before_action :set_listing, only: :show
  before_action :set_categories, only: %i[index new]

  def index
    @listings = Listing.visible.includes(:category, :user, :tags, logo_attachment: :blob)
    @listings = @listings.where(category: @category) if @category
    @listings = @listings.order(created_at: :desc)
  end

  def show
    tag_ids = @listing.tag_ids

    @similar_listings = if tag_ids.any?
      # Find listings with shared tags, ordered by number of matches
      Listing.visible
        .joins(:listing_tags)
        .where(listing_tags: { tag_id: tag_ids })
        .where.not(id: @listing.id)
        .group(:id)
        .order("COUNT(listing_tags.id) DESC")
        .includes(:category, :tags, logo_attachment: :blob)
        .limit(3)
    else
      # Fall back to same category
      Listing.visible
        .where(category: @listing.category)
        .where.not(id: @listing.id)
        .includes(:category, :tags, logo_attachment: :blob)
        .limit(3)
    end
  end

  def new
    @listing = Listing.new
    @tags = Tag.order(:name)
  end

  def create
    @listing = Current.user.listings.build(listing_params)

    if @listing.save
      redirect_to root_path, notice: t("flash.submission_pending")
    else
      set_categories
      @tags = Tag.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_listing
    @listing = Listing.visible.includes(:tags).find(params[:id])
  end

  def set_categories
    @categories = Category.order(:name)
    @category = Category.find_by(slug: params[:category]) if params[:category]
  end

  def listing_params
    params.require(:listing).permit(:name, :url, :description, :category_id, :logo, tag_ids: [])
  end
end
