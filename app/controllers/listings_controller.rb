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
    @similar_listings = Listing.visible
      .where(category: @listing.category)
      .where.not(id: @listing.id)
      .includes(:category, logo_attachment: :blob)
      .limit(3)
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
