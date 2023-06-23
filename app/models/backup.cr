module Backup
  def self.backup_and_save
    return if lock? == true

    db_uri = URI.parse ENV["DATABASE_URL"]
    backup_file_name = "backup-#{Time.utc.to_s}-#{db_uri.host}.psql".split(" ").join("_")
    command = "PGPASSWORD=#{db_uri.password} pg_dump -F c -v -h #{db_uri.host} -U #{db_uri.user} -p #{db_uri.port} -d #{db_uri.path[1..]} -f /tmp/#{backup_file_name}"

    lock!

    system command

    puts "backup file generated"

    backup_file = File.new("/tmp/#{backup_file_name}")
    Shrine.upload(backup_file, "store")
    backup_file.delete

    unlock!
  end

  def self.lock?
    @@lock
  end

  def self.lock!
    @@lock = true
  end

  def self.unlock!
    @@lock = false
  end
end
