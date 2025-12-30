class Avo::Actions::PublishListing < Avo::BaseAction
  self.name = "Publish"
  self.message = "Are you sure you want to publish this listing?"

  def handle(query:, **_)
    query.each(&:publish!)

    succeed "#{query.count} listing(s) published."
  end
end
