# Helpers for use during deployment
module DeploymentHelpers
  # Work around fredjean/middleman-s3_sync#7 by setting the content type after
  # uploading to S3.
  def content_type(path, value)
    key = path.remove(/^\//)

    after_uploading(key) do
      puts "Setting content type of #{ key.inspect } to #{ value.inspect }."
      update(file_at(key)) do |file|
        file.content_type = value
      end
    end
  end

  private

  def after_uploading(key)
    after_s3_sync do |files_by_status|
      keys = files_by_status.values_at(:created, :updated).flatten
      yield if keys.include?(key)
    end
  end

  def file_at(key)
    ::Middleman::S3Sync.bucket.files.find { |item| item.key == key }
  end

  def update(file)
    file.reload
    file.acl = 'public-read'

    yield file

    file.save
  end
end
