# Tags Feature Design

## Overview

Add tags to listings for better discoverability. Each listing can have up to 5 tags. Tags are admin-managed with predefined seeds. Users select tags via autocomplete when submitting listings.

## Data Model

### Tag Model
- `name` (string, required, unique)
- `slug` (string, unique, auto-generated via Sluggable concern)

### ListingTag Join Model
- `listing_id` (foreign key)
- `tag_id` (foreign key)
- Composite unique index on both columns

### Associations
```ruby
# Tag
has_many :listing_tags, dependent: :destroy
has_many :listings, through: :listing_tags

# Listing
has_many :listing_tags, dependent: :destroy
has_many :tags, through: :listing_tags
validates :tags, length: { maximum: 5 }
```

## Routes

```ruby
resources :tags, only: [:index, :show]
```

- `GET /tags` - list all tags (discovery page)
- `GET /tags/:slug` - show all listings with this tag

## Controllers

### TagsController
- `index`: List all tags
- `show`: Find tag by slug, load `tag.listings.visible`, reuse listing grid partial

### ListingsController
- Add `tag_ids: []` to permitted params

## Views

### Listing Card (`listings/_card.html.erb`)
- Show first 3 tags after category badge
- Style: `badge badge-outline badge-sm`
- Each tag links to `/tags/:slug`

### Listing Show Page (`listings/show.html.erb`)
- Show all tags (up to 5)
- Same badge style, clickable links

### Listing New Form (`listings/new.html.erb`)
- Tom Select input with autocomplete
- Placeholder: "Type to search tags..."
- Selected tags shown as removable chips

### Tag Index (`tags/index.html.erb`)
- List all tags with listing counts

### Tag Show (`tags/show.html.erb`)
- Reuse category page layout
- Show tag name as header
- Grid of listings with this tag

## Admin (Avo)

Create `Avo::Resources::Tag` for full CRUD:
- Fields: name, slug (readonly), listings count
- Admins can create/edit/delete tags

## Seeds

Predefined tags by domain:

**AI:**
`chatbot`, `image-generation`, `video`, `voice`, `automation`, `writing`, `research`, `productivity`

**Cloud:**
`hosting`, `database`, `serverless`, `deployment`, `cdn`, `vps`

**Dev Tools:**
`editor`, `api`, `terminal`, `monitoring`, `documentation`, `version-control`

## JavaScript

### Tom Select Setup
- Add via importmap: `tom-select`
- Stimulus controller for initialization
- Fetches available tags, filters on input

## Files to Create

1. `app/models/tag.rb`
2. `app/models/listing_tag.rb`
3. `db/migrate/xxx_create_tags.rb`
4. `db/migrate/xxx_create_listing_tags.rb`
5. `app/controllers/tags_controller.rb`
6. `app/views/tags/index.html.erb`
7. `app/views/tags/show.html.erb`
8. `app/avo/resources/tag.rb`
9. `app/javascript/controllers/tag_select_controller.js`

## Files to Modify

1. `app/models/listing.rb` - add associations, validation
2. `app/views/listings/_card.html.erb` - show 3 tags
3. `app/views/listings/show.html.erb` - show all tags
4. `app/views/listings/new.html.erb` - Tom Select input
5. `app/controllers/listings_controller.rb` - permit tag_ids
6. `db/seeds.rb` - add tag seeds
7. `config/routes.rb` - add tags resource
8. `config/importmap.rb` - add tom-select
