# Tags Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add tagging system to listings with autocomplete selection and tag-based browsing.

**Architecture:** Tag model with many-to-many relationship to Listing via ListingTag join table. Tom Select for autocomplete UI. TagsController reuses listing grid partial for tag pages.

**Tech Stack:** Rails 8, Hotwire/Stimulus, Tom Select, DaisyUI, Avo admin

---

## Task 1: Tag Model

**Files:**
- Create: `app/models/tag.rb`
- Create: `db/migrate/XXXXXX_create_tags.rb`
- Create: `test/models/tag_test.rb`
- Create: `test/fixtures/tags.yml`

**Step 1: Write the failing test**

Create `test/models/tag_test.rb`:

```ruby
require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "validates presence of name" do
    tag = Tag.new(name: nil)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "generates slug from name" do
    tag = Tag.create!(name: "Image Generation")
    assert_equal "image-generation", tag.slug
  end

  test "validates uniqueness of slug" do
    Tag.create!(name: "Chatbot")
    duplicate = Tag.new(name: "Chatbot 2", slug: "chatbot")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "normalizes name by stripping whitespace" do
    tag = Tag.new(name: "  Automation  ")
    assert_equal "Automation", tag.name
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bin/rails test test/models/tag_test.rb`
Expected: Error - Tag model doesn't exist

**Step 3: Generate migration**

Run: `bin/rails generate model Tag name:string slug:string --no-fixture`

**Step 4: Update migration**

Edit `db/migrate/XXXXXX_create_tags.rb`:

```ruby
class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :tags, :slug, unique: true
  end
end
```

**Step 5: Run migration**

Run: `bin/rails db:migrate`

**Step 6: Implement Tag model**

Edit `app/models/tag.rb`:

```ruby
class Tag < ApplicationRecord
  include Sluggable

  has_many :listing_tags, dependent: :destroy
  has_many :listings, through: :listing_tags

  validates :name, presence: true

  normalizes :name, with: -> { _1.strip }
end
```

**Step 7: Create fixtures**

Create `test/fixtures/tags.yml`:

```yaml
chatbot:
  name: Chatbot
  slug: chatbot

automation:
  name: Automation
  slug: automation

hosting:
  name: Hosting
  slug: hosting
```

**Step 8: Run tests**

Run: `bin/rails test test/models/tag_test.rb`
Expected: All pass

**Step 9: Commit**

```bash
git add -A
git commit -m "Add Tag model with Sluggable concern"
```

---

## Task 2: ListingTag Join Model

**Files:**
- Create: `app/models/listing_tag.rb`
- Create: `db/migrate/XXXXXX_create_listing_tags.rb`
- Modify: `app/models/listing.rb`
- Modify: `test/models/listing_test.rb`

**Step 1: Write the failing test**

Add to `test/models/listing_test.rb`:

```ruby
test "can have many tags" do
  listing = listings(:published_listing)
  assert_respond_to listing, :tags
end

test "validates maximum of 5 tags" do
  listing = listings(:published_listing)
  6.times { |i| listing.tags << Tag.create!(name: "Tag #{i}") }
  assert_not listing.valid?
  assert_includes listing.errors[:tags], "are limited to 5"
end
```

**Step 2: Run test to verify it fails**

Run: `bin/rails test test/models/listing_test.rb`
Expected: Error - listing_tags table doesn't exist

**Step 3: Generate migration**

Run: `bin/rails generate model ListingTag listing:references tag:references --no-fixture`

**Step 4: Update migration**

Edit `db/migrate/XXXXXX_create_listing_tags.rb`:

```ruby
class CreateListingTags < ActiveRecord::Migration[8.1]
  def change
    create_table :listing_tags do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :listing_tags, [:listing_id, :tag_id], unique: true
  end
end
```

**Step 5: Run migration**

Run: `bin/rails db:migrate`

**Step 6: Implement ListingTag model**

Edit `app/models/listing_tag.rb`:

```ruby
class ListingTag < ApplicationRecord
  belongs_to :listing
  belongs_to :tag
end
```

**Step 7: Update Listing model**

Add to `app/models/listing.rb` after `has_one_attached :logo`:

```ruby
has_many :listing_tags, dependent: :destroy
has_many :tags, through: :listing_tags

validate :tags_limit

private

def tags_limit
  errors.add(:tags, "are limited to 5") if tags.size > 5
end
```

**Step 8: Run tests**

Run: `bin/rails test test/models/listing_test.rb`
Expected: All pass

**Step 9: Commit**

```bash
git add -A
git commit -m "Add ListingTag join model with 5-tag limit"
```

---

## Task 3: TagsController

**Files:**
- Create: `app/controllers/tags_controller.rb`
- Create: `test/controllers/tags_controller_test.rb`
- Modify: `config/routes.rb`

**Step 1: Write the failing test**

Create `test/controllers/tags_controller_test.rb`:

```ruby
require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:chatbot)
    @listing = listings(:published_listing)
    @listing.tags << @tag
  end

  test "should get index" do
    get tags_url
    assert_response :success
    assert_select "a", @tag.name
  end

  test "should get show" do
    get tag_url(@tag.slug)
    assert_response :success
    assert_select "h1", @tag.name
  end

  test "show displays listings with tag" do
    get tag_url(@tag.slug)
    assert_response :success
    assert_select ".card", count: 1
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bin/rails test test/controllers/tags_controller_test.rb`
Expected: Error - No route matches

**Step 3: Add routes**

Edit `config/routes.rb`, inside the locale scope after the category route:

```ruby
resources :tags, only: [:index, :show], param: :slug
```

**Step 4: Create controller**

Create `app/controllers/tags_controller.rb`:

```ruby
class TagsController < ApplicationController
  def index
    @tags = Tag.left_joins(:listings)
               .select("tags.*, COUNT(listings.id) AS listings_count")
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
```

**Step 5: Run tests**

Run: `bin/rails test test/controllers/tags_controller_test.rb`
Expected: Error - Missing template

**Step 6: Commit**

```bash
git add -A
git commit -m "Add TagsController with index and show actions"
```

---

## Task 4: Tag Views

**Files:**
- Create: `app/views/tags/index.html.erb`
- Create: `app/views/tags/show.html.erb`
- Modify: `config/locales/en.yml`

**Step 1: Create tags index view**

Create `app/views/tags/index.html.erb`:

```erb
<div class="max-w-4xl mx-auto">
  <h1 class="text-2xl font-bold mb-6"><%= t("tags.index.title") %></h1>

  <div class="flex flex-wrap gap-2">
    <% @tags.each do |tag| %>
      <%= link_to tag_path(tag.slug), class: "badge badge-lg badge-outline gap-2 hover:badge-primary" do %>
        <%= tag.name %>
        <span class="badge badge-sm"><%= tag.listings_count %></span>
      <% end %>
    <% end %>
  </div>
</div>
```

**Step 2: Create tags show view**

Create `app/views/tags/show.html.erb`:

```erb
<div class="max-w-6xl mx-auto">
  <%= link_to "← #{t('tags.show.back')}", tags_path, class: "btn btn-ghost btn-sm mb-4" %>

  <h1 class="text-2xl font-bold mb-6"><%= @tag.name %></h1>

  <% if @listings.any? %>
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4 sm:gap-6">
      <%= render partial: "listings/card", collection: @listings, as: :listing %>
    </div>
  <% else %>
    <p class="text-base-content/60"><%= t("tags.show.no_listings") %></p>
  <% end %>
</div>
```

**Step 3: Add translations**

Add to `config/locales/en.yml` under `en:`:

```yaml
  tags:
    index:
      title: "Browse Tags"
    show:
      back: "All Tags"
      no_listings: "No listings with this tag yet."
```

**Step 4: Run tests**

Run: `bin/rails test test/controllers/tags_controller_test.rb`
Expected: All pass

**Step 5: Commit**

```bash
git add -A
git commit -m "Add tag views for index and show"
```

---

## Task 5: Display Tags on Listing Card

**Files:**
- Modify: `app/views/listings/_card.html.erb`
- Modify: `app/controllers/listings_controller.rb`

**Step 1: Update listings controller to eager load tags**

Edit `app/controllers/listings_controller.rb`, update the index action:

```ruby
def index
  @listings = Listing.visible.includes(:category, :user, :tags, logo_attachment: :blob)
  @listings = @listings.where(category: @category) if @category
  @listings = @listings.order(created_at: :desc)
end
```

**Step 2: Add tags to card**

Edit `app/views/listings/_card.html.erb`, after the category badge (line 28):

```erb
<span class="badge badge-ghost badge-sm mt-2"><%= listing.category.name %></span>
<% if listing.tags.any? %>
  <div class="flex flex-wrap gap-1 mt-1">
    <% listing.tags.first(3).each do |tag| %>
      <%= link_to tag.name, tag_path(tag.slug), class: "badge badge-outline badge-xs hover:badge-primary" %>
    <% end %>
  </div>
<% end %>
```

**Step 3: Test manually**

Run: `bin/rails server`
Visit listings page to verify no errors

**Step 4: Commit**

```bash
git add -A
git commit -m "Display first 3 tags on listing cards"
```

---

## Task 6: Display Tags on Listing Show Page

**Files:**
- Modify: `app/views/listings/show.html.erb`
- Modify: `app/controllers/listings_controller.rb`

**Step 1: Update show action to eager load tags**

Edit `app/controllers/listings_controller.rb`, update set_listing:

```ruby
def set_listing
  @listing = Listing.visible.includes(:tags).find(params[:id])
end
```

**Step 2: Add tags to show page**

Edit `app/views/listings/show.html.erb`, after the category link (after line 27):

```erb
<% if @listing.tags.any? %>
  <div class="flex flex-wrap gap-1 mt-2">
    <% @listing.tags.each do |tag| %>
      <%= link_to tag.name, tag_path(tag.slug), class: "badge badge-outline badge-sm hover:badge-primary" %>
    <% end %>
  </div>
<% end %>
```

**Step 3: Commit**

```bash
git add -A
git commit -m "Display all tags on listing show page"
```

---

## Task 7: Tom Select Setup

**Files:**
- Modify: `config/importmap.rb`
- Create: `app/javascript/controllers/tag_select_controller.js`
- Create: `app/assets/stylesheets/tom-select.css`

**Step 1: Add Tom Select to importmap**

Run: `bin/importmap pin tom-select`

**Step 2: Create Stimulus controller**

Create `app/javascript/controllers/tag_select_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    options: Array
  }

  connect() {
    this.select = new TomSelect(this.element, {
      plugins: ['remove_button'],
      maxItems: 5,
      options: this.optionsValue.map(tag => ({ value: tag.id, text: tag.name })),
      create: false,
      placeholder: "Type to search tags..."
    })
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }
}
```

**Step 3: Add Tom Select CSS**

Create `app/assets/stylesheets/tom-select.css`:

```css
@import "tom-select/dist/css/tom-select.default.css";

.ts-wrapper {
  @apply w-full;
}

.ts-control {
  @apply input input-bordered w-full min-h-12;
}

.ts-dropdown {
  @apply bg-base-100 border border-base-300 rounded-box shadow-lg;
}

.ts-dropdown .option {
  @apply px-4 py-2 cursor-pointer;
}

.ts-dropdown .option.active {
  @apply bg-primary text-primary-content;
}
```

**Step 4: Commit**

```bash
git add -A
git commit -m "Set up Tom Select with Stimulus controller"
```

---

## Task 8: Tag Selection in Listing Form

**Files:**
- Modify: `app/views/listings/new.html.erb`
- Modify: `app/controllers/listings_controller.rb`

**Step 1: Add tags to permitted params**

Edit `app/controllers/listings_controller.rb`, update listing_params:

```ruby
def listing_params
  params.require(:listing).permit(:name, :url, :description, :category_id, :logo, tag_ids: [])
end
```

**Step 2: Load tags in new action**

Edit `app/controllers/listings_controller.rb`, update set_categories or new action:

```ruby
def new
  @listing = Listing.new
  @tags = Tag.order(:name)
end
```

Also add `@tags = Tag.order(:name)` to the create action's error branch:

```ruby
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
```

**Step 3: Add tag select to form**

Edit `app/views/listings/new.html.erb`, add after the category fieldset:

```erb
<fieldset class="fieldset">
  <legend class="fieldset-legend"><%= t("listings.new.tags") %></legend>
  <%= f.select :tag_ids,
      @tags.map { |t| [t.name, t.id] },
      {},
      {
        multiple: true,
        data: {
          controller: "tag-select",
          tag_select_options_value: @tags.map { |t| { id: t.id, name: t.name } }.to_json
        }
      } %>
  <p class="label"><%= t("listings.new.tags_hint") %></p>
</fieldset>
```

**Step 4: Add translations**

Add to `config/locales/en.yml` under `listings.new`:

```yaml
      tags: "Tags"
      tags_hint: "Select up to 5 tags (optional)"
```

**Step 5: Run server and test manually**

Run: `bin/rails server`
Test the tag selection in the new listing form

**Step 6: Commit**

```bash
git add -A
git commit -m "Add tag selection to listing form with Tom Select"
```

---

## Task 9: Avo Resource for Tags

**Files:**
- Create: `app/avo/resources/tag.rb`
- Modify: `app/avo/resources/listing.rb`

**Step 1: Create Tag resource**

Create `app/avo/resources/tag.rb`:

```ruby
class Avo::Resources::Tag < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :slug, as: :text, readonly: true
    field :listings, as: :has_many
  end
end
```

**Step 2: Add tags to Listing resource**

Edit `app/avo/resources/listing.rb`, add:

```ruby
field :tags, as: :has_many
```

**Step 3: Test in Avo admin**

Run: `bin/rails server`
Visit `/avo/resources/tags` to verify CRUD works

**Step 4: Commit**

```bash
git add -A
git commit -m "Add Avo resource for Tag management"
```

---

## Task 10: Seed Tags

**Files:**
- Modify: `db/seeds.rb`

**Step 1: Add tag seeds**

Add to `db/seeds.rb` after category creation:

```ruby
# Tags
tags_data = [
  # AI
  "Chatbot", "Image Generation", "Video Generation", "Voice Synthesis",
  "Automation", "Writing Assistant", "Research", "Productivity",
  # Cloud
  "Hosting", "Database", "Serverless", "Deployment", "CDN", "VPS",
  # Dev Tools
  "Code Editor", "API Tool", "Terminal", "Monitoring", "Documentation", "Version Control"
]

tags_data.each do |name|
  Tag.find_or_create_by!(name: name)
end

puts "Created #{Tag.count} tags"
```

**Step 2: Run seeds**

Run: `bin/rails db:seed`
Expected: Tags created successfully

**Step 3: Commit**

```bash
git add -A
git commit -m "Add predefined tags to seeds"
```

---

## Task 11: Add Chinese Translations

**Files:**
- Modify: `config/locales/zh-CN.yml`

**Step 1: Add Chinese translations**

Add to `config/locales/zh-CN.yml`:

```yaml
  tags:
    index:
      title: "浏览标签"
    show:
      back: "所有标签"
      no_listings: "暂无此标签的项目。"
  listings:
    new:
      tags: "标签"
      tags_hint: "最多选择5个标签（可选）"
```

**Step 2: Commit**

```bash
git add -A
git commit -m "Add Chinese translations for tags feature"
```

---

## Task 12: Final Testing

**Step 1: Run full test suite**

Run: `bin/rails test`
Expected: All tests pass

**Step 2: Manual testing checklist**

- [ ] Create a new listing with tags
- [ ] View listing card shows first 3 tags
- [ ] View listing show page shows all tags
- [ ] Click tag goes to tag page
- [ ] Tag page shows all listings with that tag
- [ ] Tags index page shows all tags with counts
- [ ] Avo admin can create/edit/delete tags
- [ ] Works in both English and Chinese

**Step 3: Final commit**

```bash
git add -A
git commit -m "Complete tags feature implementation"
```
