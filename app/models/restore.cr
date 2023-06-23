module Restore
  def self.restore(key)
    return if lock? == true

    db_uri = URI.parse ENV["RESTORE_DATABASE_URL"]

    lock!

    backup_file = AWS_CLIENT.get_object(ENV["AWS_BUCKET"], key).body
    File.open("/tmp/backup", "w") do |file|
      file.puts backup_file
    end

    command = "PGPASSWORD=#{db_uri.password} pg_restore -c -C -F c -v -w -h #{db_uri.host} -U #{db_uri.user} -p #{db_uri.port} -d #{db_uri.path[1..]} /tmp/backup"

    puts command
    system command

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
