require 'nokogiri'
require 'simple-rss'
require 'open-uri'
require 'paint'
require 'hashr'


class RssPull

  def initialize url
    @source_url = url
    tmp = open(url).read
    @doc = Nokogiri::XML tmp

    if html?
      puts "[ loaded html document ]"
      @doc = Nokogiri::HTML tmp
      @feeds = parse_feed_urls
      @feeds.each{|feed|
        if feed.type == "rss" or feed.type == "atom"
          puts "[ loading feed ] #{feed.url}"
          @feed = load_feed feed.url
          break
        end
      }
    elsif feed?
      puts "[ loaded feed document ] #{identify}"
      @feed = load_feed url
    end

    unless @feed.nil?
      print_feed @feed
    end

  end

  # returns name of first element (preferably :html, :rss or :ieed)
  # this will become smarter later
  def identify doc = @doc
    doc.elements.first.name.to_sym
  end

  def feed?
    identify == :feed or identify == :rss
  end

  def html?
    identify == :html
  end

  def parse_feed_urls doc = @doc
    puts "[ extracting feed urls ]"
    feeds = doc.xpath("//head/link[@rel='alternate']").map { |link|
      href = link.attribute('href')
      if link.attribute('type').to_s.include? "atom"
        Hashr.new(url:link.attribute('href'), type:"atom")
      elsif link.attribute('type').to_s.include? "rss"
        Hashr.new(url:link.attribute('href'), type:"rss")
      end
    }
    return feeds
  end

  def load_feed url
    @feed = SimpleRSS.parse open(url)
    @feed.channel.title # => "Slashdot"
    @feed.channel.link # => "http://slashdot.org/"
    @feed.items.first.link # => "http://books.slashdot.org/article.pl?sid=05/08/29/1319236&amp;from=rss"

    return @feed
  end

  def print_feed feed = @feed
    feed.items.each {|item|
      puts Paint[item.title, :bold, :italic, :bright]
      puts Paint[item.link, :blue ]
      if item.description
      puts Paint[item.description]
      end
      if item.summary
      puts 
      puts Paint[item.summary]
      elsif item.content
      puts 
      puts Paint[item.content, :italic]
      end
      puts "\n\n"
    }
  end
end

