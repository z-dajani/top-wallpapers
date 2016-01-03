module ImagePostHelper
  def wrap_in_li(str)
    "<li>#{h str}</li>".html_safe
  end
end
