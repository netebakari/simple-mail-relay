require 'mail'
require 'date'
require 'fileutils'

raw = STDIN.read

date = DateTime.now.strftime("%Y-%m-%d")
timestamp = DateTime.now.strftime("%Y%m%d_%H%M%S.%L")

unless Dir.exists?("/mailraw/#{date}") then
  Dir.mkdir("/mailraw/#{date}")
  FileUtils.chmod(0777, "/mailraw/#{date}")
end
open("/mailraw/#{date}/#{timestamp}.txt", "a"){|f| f.puts raw}

FileUtils.chmod(0666, "/mailraw/#{date}/#{timestamp}.txt")

raw.force_encoding("utf-8")
mail = Mail.new(raw)

open("/maillist/#{date}.csv", "a"){|f|
  f.puts [DateTime.now.to_s, mail.to, mail.from, mail.cc, mail.subject, mail.sender].join("\t")
}
FileUtils.chmod(0666, "/maillist/#{date}.csv")
