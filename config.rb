require 'active_support'
require 'active_support/core_ext'
require 'helpers/content_helpers'
require 'lib/deployment_helpers'

extend DeploymentHelpers
helpers ContentHelpers

#
# Routing
#

# Pretty home path
proxy data.routing.home, config.index_file, ignore: true

# Redirects
activate :s3_redirect do |s3|
  s3.bucket      = data.deployment.base.host
  s3.region      = data.deployment.region
  s3.after_build = false
end
redirect config.http_prefix, absolute_url(data.routing.home)
redirect '/humans.txt', data.routing.github

# Unique asset URLs
activate :asset_hash

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
