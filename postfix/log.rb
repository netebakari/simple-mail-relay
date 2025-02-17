require 'mail'
require 'date'
require 'fileutils'

raw = STDIN.read

date = DateTime.now.strftime("%Y-%m-%d")
timestamp = DateTime.now.strftime("%Y%m%d_%H%M%S.%L")

unless Dir.exist?("/maillogs/raw/#{date}") then
  Dir.mkdir("/maillogs/raw/#{date}")
  FileUtils.chmod(0777, "/maillogs/raw/#{date}")
end
open("/maillogs/raw/#{date}/#{timestamp}.txt", "a"){|f| f.puts raw}

FileUtils.chmod(0666, "/maillogs/raw/#{date}/#{timestamp}.txt")

raw.force_encoding("utf-8")
mail = Mail.new(raw)

def join_something(str)
  return "-" if str == nil
  return str if str.is_a?(String)
  return str.join(",") if str.is_a?(Array)
  return str.to_s
end

to      = join_something(mail.to)
from    = join_something(mail.from)
cc      = join_something(mail.cc)
subject = mail.subject.gsub("\t", " ")

open("/maillogs/list/#{date}.csv", "a"){|f|
  f.puts [DateTime.now.to_s, to, from, cc, subject, mail.sender].join("\t")
}

FileUtils.chmod(0666, "/maillogs/list/#{date}.csv")
