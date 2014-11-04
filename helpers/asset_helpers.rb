require 'base64'

# Helpers for manipulating site assets
module AssetHelpers
  # Inline image
  def inline_image(path, **options)
    asset = sprockets[ignored(path)]

    image_tag(data_uri(asset), options)
  end

  # Inline script
  def inline_javascript(path, **options)
    asset = sprockets["#{ ignored(path) }.js"]

    content_tag(:script, asset.to_s, { type: 'text/javascript' }.merge(options))
  end

  # Inline stylesheet
  def inline_stylesheet(path, **options)
    asset = sprockets["#{ ignored(path) }.css"]

    content_tag(:style, asset.to_s, { type: 'text/css' }.merge(options))
  end

  private

  def data_uri(asset)
    base64 = Base64.strict_encode64(asset.to_s)

    "data:#{ asset.content_type };base64,#{ base64 }"
  end

  def ignored(path)
    path.sub(/([^\/]+)$/, '_\1')
  end
end
