require 'active_support'
require 'active_support/core_ext'
require 'lib/deployment_helpers'

#
# Routing
#

# Unique asset URLs
activate :asset_hash

# Home path
proxy data.routing.home,
      File.join(config.http_prefix, config.index_file),
      ignore: true

# Root path, home path with trailing slash
activate :s3_redirect do |s3|
  s3.bucket      = data.deployment.base.host
  s3.region      = data.deployment.region
  s3.after_build = false
end
data.deployment.base.merge(data.routing.home).tap do |home|
  [config.http_prefix, data.routing.home].each do |path|
    redirect File.join(path, config.index_file), home
  end
end

# Humans
redirect '/humans.txt', data.routing.github

#
# Content
#

activate :autoprefixer do |config|
  # Workaround for porada/middleman-autoprefixer#12
  config.browsers = ['> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1']
  config.inline = true
end

#
# Deployment
#

helpers DeploymentHelpers

# Optimization
configure :build do
  activate :gzip, exts: ['', '.js', '.css', '.html']
  activate :minify_css, inline: true
  activate :minify_html
  activate :minify_javascript, inline: true
end

# Static hosting
activate :s3_sync do |s3|
  s3.bucket = data.deployment.base.host
  s3.region = data.deployment.region
end
content_type data.routing.home, 'text/html'

# Caching
default_caching_policy max_age: 1.year, public: true
activate :cdn do |cdn|
  cdn.after_build = false
  cdn.cloudflare  = { base_urls: [data.deployment.base.to_s],
                      zone:      data.deployment.base.host }
end
after_s3_sync do |files_by_status|
  cdn_invalidate files_by_status[:updated]
end
