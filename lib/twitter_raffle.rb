require 'rubygems'
require 'httparty'
require 'json/pure'
require 'cgi'

module Twitter
  class Raffle
    include HTTParty
    base_uri 'search.twitter.com'

    attr_reader :twittes, :hashtag, :winner

    def initialize(tag)
      @twittes = []
      self.hashtag = tag
      retrieve(search_url)
      # @winner = Winner.new(@twittes[rand(@twittes.size)])
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
      retrieve "/search.json#{page}"
    end

    def retrieve(url)
      response = self.class.get(url)
      # response["results"].each { |r| @twittes << r }
      # next_page(response["next_page"]) if response["next_page"]
    # rescue JSON::ParserError => e
    #   raise "Json parse error, probably corrupt data."
    # rescue => e
    #   raise "Fail to receive twitter data."
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