require 'open-uri'

pages = 142
pct = 0.05
min = 0.01
earn = [0,0,0,0,0,0,0]
page = 0

for i in 0..pages*3
  puts "------- Page "+String(page+1)+":"
  if (page >= pages)
    break
  end
  got = false
  search = String("")
  open("http://steamcommunity.com/market/search?q=&start="+String(page*10)) do |fp|
    search = fp.read
  end
  search.lines.map(&:chomp).each do |line|
    if line =~ /<a class="market_listing_row_link" href="(.*)">/
      got = true
      ilink = /<a class="market_listing_row_link" href="(.*)">/.match(line)
      item = String("")
      open(ilink[1]) do |fp|
        item = fp.read
      end
      price = 0.0
      sold = 0
      name = String("")
      item.lines.map(&:chomp).each do |iline|
        if /line1=\[.*\[.*,.*,.*[0-9]+.*"\],\[.*\]\];/ =~ iline
          sold = /line1=\[.*\[.*,.*,"([0-9]+) .*"\],\[.*\]\];/.match(iline)
          sold = Integer(sold[1])
        end
        if /line1=\[.*\[.*,.+,.*"\],\[.*\]\];/ =~ iline
          price = /line1=\[.*\[.*,(.+),.*"\],\[.*\]\];/.match(iline)
          price = Float(price[1])
        end
        if /<span .* class="market_listing_item_name".*>.*<\/span>/ =~ iline
          name = /<span .* class="market_listing_item_name".*>(.*)<\/span>/.match(iline)
        end
      end
      if sold > 0 && price > 0 && name.length > 0
        if price * pct < min
            earn[1] = earn[1]+sold*min
            puts name[1]+": "+String(Float(sold*min).round(2))+"EUR (sold "+String(sold)+"pcs for "+String(price.round(3))+" in avg.)"
          else
            earn[1] = earn[1]+sold*price*pct
          puts name[1]+": "+String(Float(sold*price*pct).round(2))+"EUR (sold "+String(sold)+"pcs for "+String(price.round(3))+" in avg.)"
        end
      else
        if name != nil && name[1] != nil
          puts name[1]+": No data"
        end
      end
    end
  end
  if got
    page = page + 1
  end
  puts "------- So far steam got "+String(earn[1])+"EUR"
end

puts "Steam's earn from yesterdays market sale fees: "+String(earn[1])+"EUR"
