require 'rubygems'
require 'net/http'
require 'json/pure'
require 'cgi'

module Twitter
  class Raffle
    BASE_URI = 'search.twitter.com'

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
      "/search.json?rpp=100&q=" + CGI::escape(hashtag)
    end

    def next_page(page)
      retrieve("/search.json#{page}")
    end

    def retrieve(url)
      response = Net::HTTP.new(BASE_URI).get2(url, { 'User-Agent' => 'twicket' } )
      result   = JSON.parse(response.body)

      unless result["results"].nil?
        result["results"].each { |t| @twittes << t if valid?(t) }
        next_page(result["next_page"]) if result["next_page"]
      end
    rescue JSON::ParserError => e
      raise "Json parse error, probably corrupt data."
    rescue => e
      raise "Fail to receive twitter data."
    end

    def valid?(twitte)
      @twittes.each do |t|
        return false if t['from_user'] == twitte['from_user']
      end
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