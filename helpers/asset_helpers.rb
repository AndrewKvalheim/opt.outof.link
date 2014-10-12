require 'base64'

# Helpers for manipulating site assets
module AssetHelpers
  # Inline image
  def inline_image(name, **options)
    asset = sprockets[name]

    image_tag(data_uri(asset), options)
  end

  # Inline script
  def inline_javascript(path, **options)
    asset = sprockets["_#{ path }.js"]

    with_options type: 'text/javascript' do |context|
      context.content_tag(:script, asset.to_s, options)
    end
  end

  # Inline stylesheet
  def inline_stylesheet(path, **options)
    asset = sprockets["_#{ path }.css"]

    with_options type: 'text/css' do |context|
      context.content_tag(:style, asset.to_s, options)
    end
  end

  private

  def data_uri(asset)
    base64 = Base64.strict_encode64(asset.to_s)

    "data:#{ asset.content_type };base64,#{ base64 }"
  end
end
