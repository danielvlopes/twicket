require './lib/partial'
require './lib/twitter'

include Sinatra::Partials
include Twitter

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  erb :index
end

post '/' do
  @promo = Twitter::Raffle.new(params[:hashtag])
  erb :result
end