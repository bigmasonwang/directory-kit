# Dirkit

A modern Rails 8 directory starter kit for building community directories, product listings, or SaaS marketplaces.

## Features

### Core
- **Listings** - User-submitted items with logo uploads, URLs, and descriptions
- **Categories** - Organize listings into browsable categories
- **Tags** - Flexible tagging system (up to 5 tags per listing)
- **Blog** - Markdown-powered blog with scheduled publishing
- **Alternatives** - Auto-suggest similar listings based on shared tags/categories

### Authentication & Admin
- **Google OAuth** - One-click sign in with Google
- **Avo Admin Panel** - Full-featured admin dashboard at `/avo`
- **Moderation Workflow** - Listings start as pending, admin publishes or rejects

### Frontend
- **Tailwind CSS + DaisyUI** - Modern, responsive UI components
- **Hotwire** - Turbo + Stimulus for SPA-like experience without heavy JavaScript
- **Tom Select** - Enhanced multi-select for tags

### Internationalization
- **Multi-language** - English and Simplified Chinese out of the box
- **URL-based locale** - Clean URLs with optional locale prefix (`/zh-CN/...`)
- **i18n-tasks** - CLI tool to detect missing/unused translations

### Production Ready
- **SQLite** - Zero-config database with multi-database support
- **Solid Queue** - Background jobs without Redis
- **Solid Cache** - Caching without Redis
- **Active Storage** - File uploads with image processing
- **Kamal** - Docker deployment to any server

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Rails 8.1 |
| Database | SQLite3 |
| CSS | Tailwind CSS 4 + DaisyUI |
| JavaScript | Hotwire (Turbo + Stimulus) |
| Admin | Avo 3 |
| Auth | OmniAuth (Google OAuth2) |
| Markdown | Marksmith + CommonMarker |
| Jobs | Solid Queue |
| Cache | Solid Cache |
| Deployment | Kamal + Docker |

## Setup

### Prerequisites
- Ruby 3.4+
- SQLite3

### Installation

```bash
# Clone the repository
git clone https://github.com/user/dirkit.git
cd dirkit

# Install dependencies
bundle install

# Setup database
bin/rails db:prepare

# Start the server
bin/dev
```

### Configuration

1. **Google OAuth** - Add credentials to `config/credentials.yml.enc`:
   ```yaml
   google:
     client_id: your_client_id
     client_secret: your_client_secret
   ```

2. **Make yourself admin** - After signing in:
   ```bash
   bin/rails runner "User.find_by(email: 'you@example.com').update(admin: true)"
   ```

## Deployment with Kamal

### Prerequisites
- A server with SSH access (Ubuntu recommended)
- Docker installed on the server
- Domain pointing to server IP

### Configuration

1. **Set your server IP** in `.env`:
   ```bash
   SERVER_IP_ADDRESS=your.server.ip
   ```

2. **Set your domain** in `config/deploy.yml`:
   ```yaml
   proxy:
     ssl: true
     host: yourdomain.com
   ```

3. **Create master key** (if not exists):
   ```bash
   bin/rails credentials:edit
   ```

### Deploy

```bash
# First-time setup
bundle exec dotenv bin/kamal setup

# Deploy updates
bundle exec dotenv bin/kamal deploy

# View logs
bundle exec dotenv bin/kamal logs

# Rails console
bundle exec dotenv bin/kamal console

# Database console
bundle exec dotenv bin/kamal dbconsole
```

### Storage

Kamal is configured with a persistent volume for:
- SQLite databases (primary, cache, queue, cable)
- Active Storage uploads

Data persists across deployments automatically.

### SSL/TLS

SSL is enabled by default via Let's Encrypt. Kamal's proxy handles certificate provisioning automatically.

To force HTTPS, uncomment in `config/environments/production.rb`:
```ruby
config.assume_ssl = true
config.force_ssl = true
```

## i18n

### Adding a new locale

1. Create locale file `config/locales/xx.yml`
2. Add locale to `config/application.rb`:
   ```ruby
   config.i18n.available_locales = [:en, :"zh-CN", :xx]
   ```
3. Update route constraint in `config/routes.rb`:
   ```ruby
   scope "(:locale)", locale: /en|zh-CN|xx/ do
   ```

### Check translations

```bash
# Overall health check
bundle exec i18n-tasks health

# Find missing translations
bundle exec i18n-tasks missing

# Find unused translations
bundle exec i18n-tasks unused
```

## Development

```bash
# Run tests
bin/rails test

# Lint code
bin/rubocop

# Security audit
bin/brakeman
bundle exec bundler-audit check --update
```

## License

MIT
