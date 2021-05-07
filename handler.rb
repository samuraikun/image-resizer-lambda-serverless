require_relative "./lib/image_service"

def handler(event:, context:)
  key     = event["Records"][0].dig("s3", "object", "key")
  resizer = ImageService::Resizer.new(key, 280)

  resizer.resize!
end
