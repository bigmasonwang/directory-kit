# Blog Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Admin-only blog with markdown editing in Avo and public display at `/blog`.

**Architecture:** Posts managed via Avo with marksmith markdown editor. Scheduled publishing using `published_at` field — nil is draft, future is scheduled, past is live. Public routes at `/blog` (index) and `/blog/:slug` (show).

**Tech Stack:** Rails 8.1, Avo 3.x, marksmith + commonmarker gems, DaisyUI for styling.

---

## Task 1: Add gem dependencies

**Files:**
- Modify: `Gemfile:77`

**Step 1: Add gems to Gemfile**

Add after line 77 (`gem "avo", ">= 3.2"`):

```ruby
gem "marksmith"
gem "commonmarker"
```

**Step 2: Install gems**

Run: `bundle install`
Expected: Gems installed successfully

**Step 3: Commit**

```bash
git add Gemfile Gemfile.lock
git commit -m "Add marksmith and commonmarker gems for blog"
```

---

## Task 2: Create Post model with migration

**Files:**
- Create: `db/migrate/YYYYMMDDHHMMSS_create_posts.rb`
- Create: `app/models/post.rb`
- Create: `test/fixtures/posts.yml`

**Step 1: Generate migration**

Run: `bin/rails generate migration CreatePosts title:string:null body:text:null slug:string:null published_at:datetime`

**Step 2: Edit migration to add indexes**

Update the generated migration file:

```ruby
class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :slug, null: false
      t.datetime :published_at

      t.timestamps
    end
    add_index :posts, :slug, unique: true
    add_index :posts, :published_at
  end
end
```

**Step 3: Run migration**

Run: `bin/rails db:migrate`
Expected: Migration runs successfully

**Step 4: Create Post model**

Create `app/models/post.rb`:

```ruby
class Post < ApplicationRecord
  include Sluggable

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where("published_at <= ?", Time.current) }

  def name
    title
  end

  def draft?
    published_at.nil?
  end

  def scheduled?
    published_at.present? && published_at > Time.current
  end

  def published?
    published_at.present? && published_at <= Time.current
  end
end
```

**Step 5: Create fixtures**

Create `test/fixtures/posts.yml`:

```yaml
published_post:
  title: "First Blog Post"
  slug: "first-blog-post"
  body: "This is the **body** of the first post."
  published_at: <%= 1.day.ago %>

draft_post:
  title: "Draft Post"
  slug: "draft-post"
  body: "This post is not published yet."
  published_at: null

scheduled_post:
  title: "Scheduled Post"
  slug: "scheduled-post"
  body: "This post will be published tomorrow."
  published_at: <%= 1.day.from_now %>
```

**Step 6: Commit**

```bash
git add db/migrate/*_create_posts.rb app/models/post.rb test/fixtures/posts.yml db/schema.rb
git commit -m "Add Post model with Sluggable and published scope"
```

---

## Task 3: Add Post model tests

**Files:**
- Create: `test/models/post_test.rb`

**Step 1: Write model tests**

Create `test/models/post_test.rb`:

```ruby
require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "validates presence of title" do
    post = Post.new(title: nil, body: "Content")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "validates presence of body" do
    post = Post.new(title: "Title", body: nil)
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "generates slug from title" do
    post = Post.create!(title: "My First Post", body: "Content")
    assert_equal "my-first-post", post.slug
  end

  test "validates uniqueness of slug" do
    duplicate = Post.new(title: "First Blog Post 2", slug: "first-blog-post", body: "Content")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "published scope returns only published posts" do
    published = posts(:published_post)
    draft = posts(:draft_post)
    scheduled = posts(:scheduled_post)

    results = Post.published

    assert_includes results, published
    assert_not_includes results, draft
    assert_not_includes results, scheduled
  end

  test "draft? returns true when published_at is nil" do
    assert posts(:draft_post).draft?
    assert_not posts(:published_post).draft?
  end

  test "scheduled? returns true when published_at is in the future" do
    assert posts(:scheduled_post).scheduled?
    assert_not posts(:published_post).scheduled?
  end

  test "published? returns true when published_at is in the past" do
    assert posts(:published_post).published?
    assert_not posts(:draft_post).published?
    assert_not posts(:scheduled_post).published?
  end
end
```

**Step 2: Run tests to verify they pass**

Run: `bin/rails test test/models/post_test.rb`
Expected: All tests pass

**Step 3: Commit**

```bash
git add test/models/post_test.rb
git commit -m "Add Post model tests"
```

---

## Task 4: Create Avo resource for Post

**Files:**
- Create: `app/avo/resources/post.rb`

**Step 1: Create Avo resource**

Create `app/avo/resources/post.rb`:

```ruby
class Avo::Resources::Post < Avo::BaseResource
  def fields
    field :id, as: :id
    field :title, as: :text
    field :body, as: :markdown
    field :slug, as: :text, readonly: true
    field :published_at, as: :datetime
  end
end
```

**Step 2: Verify in browser (manual)**

Visit `/avo/resources/posts` after logging in as admin.
Expected: Post resource appears with markdown editor for body field.

**Step 3: Commit**

```bash
git add app/avo/resources/post.rb
git commit -m "Add Avo resource for Post with markdown field"
```

---

## Task 5: Add blog routes

**Files:**
- Modify: `config/routes.rb`

**Step 1: Add routes inside locale scope**

Add inside the `scope "(:locale)"` block in `config/routes.rb`:

```ruby
resources :posts, only: [:index, :show], param: :slug, path: "blog"
```

**Step 2: Verify routes**

Run: `bin/rails routes | grep posts`
Expected:
```
posts GET  (/:locale)/blog(.:format)           posts#index
post  GET  (/:locale)/blog/:slug(.:format)     posts#show
```

**Step 3: Commit**

```bash
git add config/routes.rb
git commit -m "Add blog routes at /blog"
```

---

## Task 6: Create PostsController

**Files:**
- Create: `app/controllers/posts_controller.rb`

**Step 1: Create controller**

Create `app/controllers/posts_controller.rb`:

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.published.order(published_at: :desc)
  end

  def show
    @post = Post.published.find_by!(slug: params[:slug])
  end
end
```

**Step 2: Commit**

```bash
git add app/controllers/posts_controller.rb
git commit -m "Add PostsController with index and show actions"
```

---

## Task 7: Add PostsController tests

**Files:**
- Create: `test/controllers/posts_controller_test.rb`

**Step 1: Write controller tests**

Create `test/controllers/posts_controller_test.rb`:

```ruby
require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = posts(:published_post)
    @draft = posts(:draft_post)
    @scheduled = posts(:scheduled_post)
  end

  test "index returns success" do
    get posts_url
    assert_response :success
  end

  test "index shows published posts" do
    get posts_url
    assert_match @published.title, response.body
  end

  test "index does not show draft posts" do
    get posts_url
    assert_no_match @draft.title, response.body
  end

  test "index does not show scheduled posts" do
    get posts_url
    assert_no_match @scheduled.title, response.body
  end

  test "show returns success for published post" do
    get post_url(slug: @published.slug)
    assert_response :success
  end

  test "show displays post content" do
    get post_url(slug: @published.slug)
    assert_match @published.title, response.body
  end

  test "show returns 404 for draft post" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get post_url(slug: @draft.slug)
    end
  end

  test "show returns 404 for scheduled post" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get post_url(slug: @scheduled.slug)
    end
  end

  test "show returns 404 for nonexistent slug" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get post_url(slug: "nonexistent")
    end
  end
end
```

**Step 2: Run tests to verify they pass**

Run: `bin/rails test test/controllers/posts_controller_test.rb`
Expected: All tests pass

**Step 3: Commit**

```bash
git add test/controllers/posts_controller_test.rb
git commit -m "Add PostsController tests"
```

---

## Task 8: Create blog views

**Files:**
- Create: `app/views/posts/index.html.erb`
- Create: `app/views/posts/show.html.erb`
- Create: `app/helpers/posts_helper.rb`

**Step 1: Create markdown helper**

Create `app/helpers/posts_helper.rb`:

```ruby
module PostsHelper
  def render_markdown(text)
    raw Commonmarker.to_html(text)
  end
end
```

**Step 2: Create index view**

Create `app/views/posts/index.html.erb`:

```erb
<div class="max-w-2xl mx-auto">
  <h1 class="text-2xl font-bold mb-6">Blog</h1>

  <% if @posts.any? %>
    <div class="space-y-6">
      <% @posts.each do |post| %>
        <article class="card card-border bg-base-100">
          <div class="card-body">
            <h2 class="card-title">
              <%= link_to post.title, post_path(slug: post.slug), class: "link link-hover" %>
            </h2>
            <p class="text-sm text-base-content/60">
              <%= post.published_at.strftime("%B %d, %Y") %>
            </p>
          </div>
        </article>
      <% end %>
    </div>
  <% else %>
    <p class="text-base-content/60">No posts yet.</p>
  <% end %>
</div>
```

**Step 3: Create show view**

Create `app/views/posts/show.html.erb`:

```erb
<div class="max-w-2xl mx-auto">
  <%= link_to "← Back to Blog", posts_path, class: "btn btn-ghost btn-sm mb-4" %>

  <article class="card card-border bg-base-100">
    <div class="card-body">
      <h1 class="card-title text-2xl"><%= @post.title %></h1>
      <p class="text-sm text-base-content/60">
        <%= @post.published_at.strftime("%B %d, %Y") %>
      </p>

      <div class="divider"></div>

      <div class="prose max-w-none">
        <%= render_markdown(@post.body) %>
      </div>
    </div>
  </article>
</div>
```

**Step 4: Verify in browser (manual)**

Create a test post in Avo with `published_at` set to now.
Visit `/blog` — should show the post.
Click the post — should render markdown body.

**Step 5: Commit**

```bash
git add app/helpers/posts_helper.rb app/views/posts/
git commit -m "Add blog views with markdown rendering"
```

---

## Task 9: Run full test suite

**Step 1: Run all tests**

Run: `bin/rails test`
Expected: All tests pass

**Step 2: Final commit if any cleanup needed**

---

## Summary

After completing all tasks:
- Blog posts managed in Avo at `/avo/resources/posts`
- Markdown editor with preview for post body
- Public blog at `/blog` (index) and `/blog/:slug` (show)
- Scheduled publishing via `published_at` field
