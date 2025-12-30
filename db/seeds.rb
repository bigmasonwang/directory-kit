# Categories
categories = [
  { name: "Hosting", description: "Web hosting and cloud providers" },
  { name: "Dev Tools", description: "Developer tools and utilities" },
  { name: "Databases", description: "Database services and tools" },
  { name: "Analytics", description: "Analytics and monitoring services" },
  { name: "Design", description: "Design tools and resources" }
]

categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |cat|
    cat.description = attrs[:description]
  end
end

puts "Created #{Category.count} categories"
