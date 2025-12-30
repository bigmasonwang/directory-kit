class Avo::Actions::RejectListing < Avo::BaseAction
  self.name = "Reject"
  self.message = "Are you sure you want to reject this listing?"

  def handle(query:, **_)
    query.each(&:reject!)

    succeed "#{query.count} listing(s) rejected."
  end
end
