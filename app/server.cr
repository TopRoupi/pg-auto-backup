# require shards
require "kemal"
require "kemal-session"
require "shrine"
require "uri"
require "dotenv"

if File.exists?("./.env")
  Dotenv.load
end

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["SECRET_KEY"]
  config.gc_interval = 2.minutes # 2 minutes
end

public_folder "app/public"

require "./shrine.cr"
require "./helpers.cr"

require "./models/backup.cr"
require "./models/restore.cr"

before_get "/" do |env|
  if env.request.path != "/login"
    env.redirect "/login" if env.session.int?("admin") == nil
  end
end

get "/" do
  objs = AWS_CLIENT.list_objects(ENV["AWS_BUCKET"]).first.contents.sort_by do |s|
    (Time.utc - s.last_modified).total_seconds.to_i
  end.reverse

  render_page "home"
end

get "/login" do
  render_page "login"
end

post "/login" do |env|
  key = env.params.body["password"].as(String)
  if key != ENV["ACCESS_PASSWORD"]
    env.redirect "/login"
  else
    env.session.int("admin", 1)
    env.redirect "/"
  end
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
