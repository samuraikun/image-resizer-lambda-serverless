require "aws-sdk-s3"
require "image_processing/vips"

module ImageService
  class Resizer
    CLIENT = Aws::S3::Client.new(region: "ap-northeast-1")
    BUCKET = "yuichi-kojima-test2"

    attr_reader :key, :size

    def initialize(key, width = 280, height = nil)
      @key = key
      @width = width
      @height = height
    end

    def resize!
      return if resized?

      resized = ImageProcessing::Vips
        .source(source)
        .resize_to_limit(@width, @height)
        .call(save: false)
        .write_to_buffer(File.extname(@key))

      put_object resized, new_key
    end

    def source
      if File.extname(@key) == ".png"
        Vips::Image.pngload_buffer(get_object)
      elsif File.extname(@key) == ".gif"
        Vips::Image.thumbnail(@key, @width)
      else
        Vips::Image.new_from_buffer(get_object, File.extname(@key))
      end
    end

    def new_key
      "resized/#{File.basename(@key, File.extname(@key))}-#{@width}#{File.extname(@key)}"
    end

    def get_object
      CLIENT.get_object(bucket: BUCKET, key: @key).body.read
    end

    def put_object(object, put_key)
      CLIENT.put_object(
        bucket: BUCKET,
        key: put_key,
        body: object,
        metadata: { resized: "1" }
      )
    end

    def resized?
      metadata[:resized]
    end

    def metadata
      response = CLIENT.head_object(bucket: BUCKET, key: @key)
      response.metadata || {}
    rescue Aws::S3::Errors::NotFound
      {}
    end
  end
end
