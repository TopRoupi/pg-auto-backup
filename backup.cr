require "shrine"
require "uri"
require "dotenv"
require "tasker"

Dotenv.load

client = Awscr::S3::Client.new(ENV["AWS_REGION"], ENV["AWS_KEY"], ENV["AWS_SECRET"])
storage = Shrine::Storage::S3.new(bucket: ENV["AWS_BUCKET"], client: client)

Shrine.configure do |config|
  # config.storages["cache"] = Storage::FileSystem.new("uploads", prefix: "cache")
  config.storages["store"] = storage
end

def backup_and_save
  db_uri = URI.parse ENV["DATABASE_URL"]
  backup_file_name = "backup-#{Time.utc.to_s}.psql".split(" ").join("_")
  command = "PGPASSWORD=#{db_uri.password} pg_dump -F c -v -h #{db_uri.host} -U #{db_uri.user} -p #{db_uri.port} -d #{db_uri.path[1..]} -f #{backup_file_name}"

  system command

  backup_file = File.new("#{backup_file_name}")
  Shrine.upload(backup_file, "store")
  backup_file.delete
end

def show_stats(client)
  client.list_objects(ENV["AWS_BUCKET"]).each do |resp|
    objs = resp.contents.sort do |s|
      (Time.utc - s.last_modified).total_minutes.to_i
    end.reverse
    puts "number of backups #{objs.size}"
    puts "total storage usage #{objs.reduce(0) { |sum, o| sum + o.size }}"
    puts "last backup size #{objs.last.size}"
  end
end

task = Tasker.every(12.hours) do
  backup_and_save
  show_stats(client)
end

p "starting loop"
loop do
  task.get
end
