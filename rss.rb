#!/bin/env ruby

require './lib/rsspull'

$*.each {|url|
  url = String.new url # ??? what did I do here?
  url.insert 0, "http://" unless url.start_with? "http://" or url.start_with? "https://"

  pull = RssPull.new url

}




