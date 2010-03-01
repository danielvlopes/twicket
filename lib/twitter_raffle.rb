require 'rubygems'
require 'net/http'
require 'json/pure'
require 'cgi'

module Twitter
  class Raffle
    attr_reader :twittes, :hashtag, :winner

    def initialize(tag)
      @twittes = []
      self.hashtag = tag
      retrieve(search_url)
      @winner = Winner.new(@twittes[rand(@twittes.size)])
    end

    def hashtag=(value)
      @hashtag = (value =~ /^#/) ? value : "##{value}"
    end
    
    def empty?
      @twittes.empty?
    end

  private
    def search_url
      "http://search.twitter.com/search.json?rpp=100&q=" + CGI::escape(hashtag)
    end

    def next_page(page)
      retrieve("http://search.twitter.com/search.json#{page}")
    end

    def retrieve(url)
      response = Net::HTTP.get_response(URI.parse(url))
      result   = JSON.parse(response.body)

      result["results"].each { |r| @twittes << r }
      next_page(result["next_page"]) if result["next_page"]

    rescue JSON::ParserError => e
      raise "Json parse error, probably corrupt data."
    rescue => e
      raise "Fail to receive twitter data."
    end
  end

  class Winner

    def initialize(attributes={})
      @attributes = attributes
    end

    def name
      @attributes["from_user"]
    end

    def twitte
      "http://twitter.com/#{@attributes["from_user"]}/status/#{@attributes["id"]}"
    end

    def to_s
      "And the winner is #{name} with: #{twitte}"
    end
  end
end