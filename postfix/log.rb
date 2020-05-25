require 'mail'
require 'date'

raw = STDIN.read

date = DateTime.now.strftime("%Y-%m-%d")
timestamp = DateTime.now.strftime("%Y%m%d_%H%M%S.%L")

Dir.mkdir("/mailraw/#{date}") unless Dir.exists?("/mailraw/#{date}")
open("/mailraw/#{date}/#{timestamp}.txt", "a"){|f| f.puts raw}

raw.force_encoding("utf-8")
mail = Mail.new(raw)

open("/maillist/#{date}.csv", "a"){|f|
  f.puts [DateTime.now.to_s, mail.to, mail.from, mail.cc, mail.subject, mail.sender].join("\t")
}
