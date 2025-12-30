# Directory Listings Design

## Overview

Dirkit is a directory app where admins manage listings and users can submit new ones for review.

## Models

### Category

| Field       | Type   | Notes                     |
|-------------|--------|---------------------------|
| name        | string | Required                  |
| slug        | string | Required, unique, for URLs|
| description | text   | Optional                  |

### Listing

| Field       | Type    | Notes                          |
|-------------|---------|--------------------------------|
| name        | string  | Required                       |
| url         | string  | Required                       |
| description | text    | Required                       |
| status      | enum    | pending/published/rejected     |
| category_id | FK      | Required, belongs_to Category  |
| user_id     | FK      | Required, belongs_to User      |
| logo        | attachment | Active Storage image        |

### Relationships

- Category has_many Listings
- User has_many Listings
- Listing belongs_to Category, User
- Listing has_one_attached :logo

## User Flows

### Public (anyone)

- Browse published listings on homepage
- Filter by category
- View listing details

### Authenticated users

- Submit new listing via form
- Listing saved as pending

### Admin (via Avo)

- CRUD categories
- CRUD listings
- Publish/Reject pending submissions

## Routes

```
GET  /                    → listings#index (homepage)
GET  /listings            → listings#index
GET  /listings/:id        → listings#show
GET  /listings/new        → listings#new (auth required)
POST /listings            → listings#create (auth required)
GET  /categories/:slug    → listings#index (filtered)
```

## Implementation Phases

### Phase 1: Models & Database

1. Create Category model with migration
2. Create Listing model with migration
3. Set up Active Storage attachment
4. Add validations and relationships

### Phase 2: Admin (Avo)

1. Category Avo resource
2. Listing Avo resource with status badges
3. Publish/Reject actions
4. Seed categories

### Phase 3: Public Pages

1. ListingsController (index/show/new/create)
2. Views with Tailwind
3. Category filter
4. Logo upload form

### Phase 4: Polish

1. Tests
2. Flash messages
3. Error handling

## Decisions

- **Listings** as the term for directory items
- **Categories only** (no tags) for organization
- **Admin approval required** for submissions
- **Signed-in users only** can submit
- **Local disk storage** for images (Active Storage)
- **Minimal homepage** with listings grid and category filter
