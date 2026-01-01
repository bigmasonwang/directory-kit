module PostsHelper
  def render_markdown(text)
    raw Commonmarker.to_html(text)
  end
end
