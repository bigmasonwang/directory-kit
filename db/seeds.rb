# Seed User (for listings ownership)
seed_user = User.find_or_create_by!(provider: "github", uid: "seed-user") do |user|
  user.email = "seed@example.com"
  user.name = "Community"
  user.admin = true
end

puts "Created seed user: #{seed_user.email}"

# Categories
categories = [
  { name: "AI Tools", description: "Artificial intelligence tools and applications" },
  { name: "Cloud Services", description: "Cloud platforms, hosting, and infrastructure services" },
  { name: "Dev Tools", description: "Developer tools and utilities" }
]

categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |cat|
    cat.description = attrs[:description]
  end
end

puts "Created #{Category.count} categories"

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

ai_tools = Category.find_by!(name: "AI Tools")

# AI Tools Listings
ai_listings = [
  # Assistants
  { name: "ChatGPT", url: "https://chatgpt.com/", description: "OpenAI's conversational AI assistant for writing, coding, analysis, and creative tasks", tags: ["Chatbot", "Writing Assistant", "Productivity"] },
  { name: "Grok", url: "https://x.com/i/grok", description: "xAI's witty AI assistant with real-time access to X posts and web information", tags: ["Chatbot", "Research"] },
  { name: "Claude", url: "https://claude.ai/", description: "Anthropic's thoughtful AI assistant known for nuanced conversations and long-context understanding", tags: ["Chatbot", "Writing Assistant", "Research"] },
  { name: "Gemini", url: "https://gemini.google.com/", description: "Google's multimodal AI assistant with deep integration into Google services", tags: ["Chatbot", "Productivity"] },
  { name: "Perplexity", url: "https://www.perplexity.ai/", description: "AI-powered answer engine that provides sourced, up-to-date responses", tags: ["Chatbot", "Research"] },
  { name: "Google AI Mode", url: "https://blog.google/products/search/ai-mode-search/", description: "Google Search with conversational AI for complex, multi-step questions", tags: ["Chatbot", "Research"] },
  # Video Generation
  { name: "Google Veo", url: "https://deepmind.google/models/veo/", description: "Google DeepMind's high-fidelity video generation model", tags: ["Video Generation"] },
  { name: "OpusClip", url: "https://www.opus.pro/", description: "AI-powered tool for repurposing long videos into viral short clips", tags: ["Video Generation", "Automation"] },
  # Image Generation
  { name: "Midjourney", url: "https://www.midjourney.com/", description: "Leading AI art generator known for stunning, artistic image creation", tags: ["Image Generation"] },
  { name: "Canva Magic Studio", url: "https://www.canva.com/magic/", description: "AI-powered design suite for creating graphics, presentations, and videos", tags: ["Image Generation", "Productivity"] },
  { name: "Looka", url: "https://looka.com/", description: "AI logo maker and brand kit generator for businesses", tags: ["Image Generation"] },
  # Meeting Assistants
  { name: "Fathom", url: "https://www.fathom.video/", description: "Free AI meeting assistant that records, transcribes, and summarizes meetings", tags: ["Productivity", "Automation"] },
  { name: "Nyota", url: "https://www.nyota.ai/", description: "AI meeting assistant for automated notes, action items, and CRM updates", tags: ["Productivity", "Automation"] },
  # Automation
  { name: "n8n", url: "https://n8n.io/", description: "Open-source workflow automation with AI capabilities and 400+ integrations", tags: ["Automation"] },
  { name: "Manus", url: "https://manus.im/", description: "AI agent that can autonomously complete tasks across the web", tags: ["Automation", "Productivity"] },
  # Research
  { name: "Deep Research", url: "https://chatgpt.com/", description: "OpenAI's research agent that explores topics in depth and synthesizes findings", tags: ["Research", "Chatbot"] },
  { name: "NotebookLM", url: "https://notebooklm.google/", description: "Google's AI research assistant that analyzes your documents and creates audio summaries", tags: ["Research", "Voice Synthesis"] },
  # Writing
  { name: "Rytr", url: "https://rytr.me/", description: "AI writing assistant for creating content in 40+ use cases and 30+ languages", tags: ["Writing Assistant"] },
  { name: "Sudowrite", url: "https://sudowrite.com/", description: "AI writing partner for fiction authors with story development tools", tags: ["Writing Assistant"] },
  # Coding Tools
  { name: "Lovable", url: "https://lovable.dev/", description: "AI-powered full-stack app builder that turns ideas into working applications", tags: ["Automation", "Productivity"] },
  { name: "Cursor", url: "https://www.cursor.com/", description: "AI-first code editor built for pair programming with AI", tags: ["Chatbot", "Productivity"] },
  # Knowledge Management
  { name: "Notion AI Q&A", url: "https://www.notion.com/product/ai", description: "AI assistant for searching and answering questions across your Notion workspace", tags: ["Productivity", "Research"] },
  { name: "Guru", url: "https://www.getguru.com/", description: "AI-powered knowledge management platform for teams", tags: ["Productivity"] },
  # Email
  { name: "HubSpot Email Writer", url: "https://www.hubspot.com/products/marketing/ai-email-writer", description: "AI email writer for marketing campaigns and sales outreach", tags: ["Writing Assistant", "Automation"] },
  { name: "Fyxer", url: "https://www.fyxer.com/", description: "AI email assistant that organizes inbox and drafts replies", tags: ["Productivity", "Automation"] },
  { name: "Shortwave", url: "https://www.shortwave.com/", description: "AI-powered email client with smart inbox management", tags: ["Productivity"] },
  # Scheduling
  { name: "Reclaim", url: "https://reclaim.ai/", description: "AI calendar assistant that automatically schedules tasks and protects focus time", tags: ["Productivity", "Automation"] },
  { name: "Clockwise", url: "https://www.getclockwise.com/", description: "AI scheduling tool that optimizes team calendars for focus and collaboration", tags: ["Productivity", "Automation"] },
  # Presentations
  { name: "Gamma", url: "https://gamma.app/", description: "AI-powered tool for creating beautiful presentations, documents, and websites", tags: ["Productivity", "Image Generation"] },
  { name: "Copilot for PowerPoint", url: "https://support.microsoft.com/en-us/copilot-powerpoint", description: "Microsoft's AI assistant for creating and enhancing PowerPoint presentations", tags: ["Productivity"] },
  # Resume Builders
  { name: "Teal", url: "https://www.tealhq.com/tools/resume-builder", description: "AI resume builder with job tracking and career growth tools", tags: ["Writing Assistant", "Productivity"] },
  { name: "Kickresume", url: "https://www.kickresume.com/", description: "AI-powered resume and cover letter builder with professional templates", tags: ["Writing Assistant"] },
  # Voice Generation
  { name: "ElevenLabs", url: "https://elevenlabs.io/", description: "Industry-leading AI voice synthesis and cloning platform", tags: ["Voice Synthesis"] },
  { name: "Murf", url: "https://murf.ai/", description: "AI voice generator for creating studio-quality voiceovers", tags: ["Voice Synthesis"] },
  # Music Generation
  { name: "Suno", url: "https://suno.com/", description: "AI music generator that creates complete songs from text prompts", tags: ["Voice Synthesis"] },
  { name: "Udio", url: "https://www.udio.com/", description: "AI music creation platform for generating high-quality songs", tags: ["Voice Synthesis"] },
  # Marketing
  { name: "AdCreative", url: "https://www.adcreative.ai/", description: "AI-powered ad creative generation for high-converting campaigns", tags: ["Image Generation", "Automation"] },
  { name: "AirOps", url: "https://www.airops.com/", description: "AI workflows for scaling content marketing and SEO", tags: ["Automation", "Writing Assistant"] },
  # Sales
  { name: "Attio", url: "https://attio.com/", description: "AI-native CRM that automatically enriches and organizes customer data", tags: ["Automation", "Productivity"] }
]

ai_listings.each do |attrs|
  listing = Listing.find_or_create_by!(name: attrs[:name]) do |l|
    l.url = attrs[:url]
    l.description = attrs[:description]
    l.category = ai_tools
    l.user = seed_user
    l.status = :published
  end
  if attrs[:tags] && listing.tags.empty?
    listing.tags = Tag.where(name: attrs[:tags])
  end
end

# Cloud Services Listings
cloud_services = Category.find_by!(name: "Cloud Services")

cloud_listings = [
  # VPS & Cloud Providers
  { name: "Hetzner", url: "https://www.hetzner.com/", description: "German cloud provider offering affordable dedicated servers, VPS, and cloud hosting", tags: ["VPS", "Hosting"] },
  { name: "AWS", url: "https://aws.amazon.com/", description: "Amazon's comprehensive cloud platform with compute, storage, databases, and 200+ services", tags: ["Hosting", "Database", "Serverless"] },
  { name: "Google Cloud", url: "https://cloud.google.com/", description: "Google's cloud platform with compute, AI/ML, data analytics, and Kubernetes services", tags: ["Hosting", "Database", "Serverless"] },
  { name: "DigitalOcean", url: "https://www.digitalocean.com/", description: "Developer-friendly cloud platform with simple pricing for droplets, databases, and Kubernetes", tags: ["VPS", "Hosting", "Database"] },
  # Deployment Platforms
  { name: "Vercel", url: "https://vercel.com/", description: "Frontend cloud platform for deploying Next.js and other frameworks with edge functions", tags: ["Deployment", "Serverless", "CDN"] },
  { name: "Netlify", url: "https://www.netlify.com/", description: "Platform for deploying modern web projects with continuous deployment and serverless functions", tags: ["Deployment", "Serverless", "CDN"] },
  { name: "Render", url: "https://render.com/", description: "Unified cloud to build and run apps with free SSL, global CDN, and auto-deploys from Git", tags: ["Deployment", "Hosting"] },
  { name: "Railway", url: "https://railway.app/", description: "Deploy apps instantly with infrastructure automation and simple scaling", tags: ["Deployment", "Hosting"] },
  { name: "Fly.io", url: "https://fly.io/", description: "Deploy app servers close to users with global edge hosting and Firecracker VMs", tags: ["Deployment", "Hosting", "CDN"] },
  # Managed Databases
  { name: "Neon", url: "https://neon.tech/", description: "Serverless Postgres with branching, autoscaling, and generous free tier", tags: ["Database", "Serverless"] },
  { name: "PlanetScale", url: "https://planetscale.com/", description: "Serverless MySQL platform with branching, schema changes, and unlimited scale", tags: ["Database", "Serverless"] },
  { name: "Supabase", url: "https://supabase.com/", description: "Open source Firebase alternative with Postgres, auth, storage, and realtime subscriptions", tags: ["Database", "Hosting"] },
  { name: "Upstash", url: "https://upstash.com/", description: "Serverless Redis and Kafka with pay-per-request pricing for edge applications", tags: ["Database", "Serverless"] }
]

cloud_listings.each do |attrs|
  listing = Listing.find_or_create_by!(name: attrs[:name]) do |l|
    l.url = attrs[:url]
    l.description = attrs[:description]
    l.category = cloud_services
    l.user = seed_user
    l.status = :published
  end
  if attrs[:tags] && listing.tags.empty?
    listing.tags = Tag.where(name: attrs[:tags])
  end
end

# Dev Tools Listings
dev_tools = Category.find_by!(name: "Dev Tools")

dev_listings = [
  # Version Control & Collaboration
  { name: "GitHub", url: "https://github.com/", description: "Code hosting platform with version control, CI/CD, and collaboration features", tags: ["Version Control"] },
  { name: "GitLab", url: "https://gitlab.com/", description: "Complete DevOps platform with Git repos, CI/CD pipelines, and security scanning", tags: ["Version Control", "Monitoring"] },
  # Code Editors
  { name: "VS Code", url: "https://code.visualstudio.com/", description: "Free, open-source code editor with extensions, debugging, and Git integration", tags: ["Code Editor"] },
  { name: "Zed", url: "https://zed.dev/", description: "High-performance code editor built in Rust with real-time collaboration", tags: ["Code Editor"] },
  # API Development
  { name: "Postman", url: "https://www.postman.com/", description: "API platform for building, testing, and documenting APIs with team collaboration", tags: ["API Tool", "Documentation"] },
  { name: "Insomnia", url: "https://insomnia.rest/", description: "Open-source API client for REST, GraphQL, and gRPC with environment management", tags: ["API Tool"] },
  { name: "Hoppscotch", url: "https://hoppscotch.io/", description: "Open-source API development ecosystem that's fast and lightweight", tags: ["API Tool"] },
  # Terminal & CLI
  { name: "Warp", url: "https://www.warp.dev/", description: "Modern terminal with AI command search, IDE-like editing, and team sharing", tags: ["Terminal"] },
  { name: "iTerm2", url: "https://iterm2.com/", description: "Feature-rich terminal emulator for macOS with split panes and search", tags: ["Terminal"] },
  # Database Tools
  { name: "TablePlus", url: "https://tableplus.com/", description: "Modern database GUI for Postgres, MySQL, SQLite, Redis, and more", tags: ["API Tool"] },
  { name: "DBeaver", url: "https://dbeaver.io/", description: "Free universal database tool supporting 80+ databases with SQL editor", tags: ["API Tool"] },
  # Documentation
  { name: "Mintlify", url: "https://mintlify.com/", description: "Beautiful documentation that converts, with AI-powered search and analytics", tags: ["Documentation"] },
  { name: "ReadMe", url: "https://readme.com/", description: "Interactive API documentation with try-it-now functionality and analytics", tags: ["Documentation", "API Tool"] },
  # Monitoring & Debugging
  { name: "Sentry", url: "https://sentry.io/", description: "Error tracking and performance monitoring for apps with detailed stack traces", tags: ["Monitoring"] },
  { name: "LogRocket", url: "https://logrocket.com/", description: "Session replay and error tracking to understand user issues in context", tags: ["Monitoring"] }
]

dev_listings.each do |attrs|
  listing = Listing.find_or_create_by!(name: attrs[:name]) do |l|
    l.url = attrs[:url]
    l.description = attrs[:description]
    l.category = dev_tools
    l.user = seed_user
    l.status = :published
  end
  if attrs[:tags] && listing.tags.empty?
    listing.tags = Tag.where(name: attrs[:tags])
  end
end

puts "Created #{Listing.count} listings"
