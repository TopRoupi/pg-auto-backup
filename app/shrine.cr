AWS_CLIENT = Awscr::S3::Client.new(ENV["AWS_REGION"], ENV["AWS_KEY"], ENV["AWS_SECRET"])
AWS_STORAGE = Shrine::Storage::S3.new(bucket: ENV["AWS_BUCKET"], client: AWS_CLIENT)

Shrine.configure do |config|
  # config.storages["cache"] = Storage::FileSystem.new("uploads", prefix: "cache")
  config.storages["store"] = AWS_STORAGE
end
