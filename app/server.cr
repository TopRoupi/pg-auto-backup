# require shards
require "kemal"
require "shrine"
require "uri"
require "dotenv"

if File.exists?("./.env")
  Dotenv.load
end

require "./shrine.cr"
require "./helpers.cr"

require "./models/backup.cr"
require "./models/restore.cr"

get "/" do
  objs = AWS_CLIENT.list_objects(ENV["AWS_BUCKET"]).first.contents.sort_by do |s|
    (Time.utc - s.last_modified).total_seconds.to_i
  end.reverse

  render_page "home"
end

post "/backup" do
  if Backup.lock? == true
    "processing"
  else
    spawn do
      Backup.backup_and_save
    end
    "the backup is processing pls wait"
  end
end

post "/backup/:key/delete" do |env|
  key = env.params.url["key"]
  AWS_STORAGE.delete key
  env.redirect "/"
end

post "/backup/:key/restore" do |env|
  key = env.params.url["key"]

  if Restore.lock? == true
    "processing"
  else
    spawn do
      Restore.restore key
    end
    "the restore is processing pls wait"
  end
end

Kemal.run
