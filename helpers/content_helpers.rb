# Helpers for manipulating site content
module ContentHelpers
  def absolute_url(path = current_page.path)
    data.deployment.base.merge(path)
  end

  def indexable?
    current_page.data.fetch('indexable', true)
  end  
end
