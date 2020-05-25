require 'mail'
require 'date'

raw = STDIN.read

# タイムスタンプ
timestamp = DateTime.now.strftime("%Y%m%d_%H%M%S.%L")
# メール本文を保存
open("/mailraw/#{timestamp}.txt", "a"){|f| f.puts raw}

raw.force_encoding("utf-8")
mail = Mail.new(raw)

date_str = DateTime.now.strftime("%Y-%m-%d")
open("/maillist/#{date_str}.csv", "a"){|f|
  f.puts [DateTime.now.to_s, mail.to, mail.from, mail.cc, mail.subject, mail.sender].join("\t")
}
