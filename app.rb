require 'sinatra'

require_relative 'lib/parser'

Dir['lib/cards/*'].each do |file|
    require_relative file
end

get '/cards/*' do
    path = "cards/#{params[:splat][0]}"

    cards = CardsParser.new.parse(File.read(path))

    @cards = cards.map { |card|
        klass = Card.descendant(card[:name])

        if klass
            klass.new(card[:text], card[:attributes])
        end
    }.compact

    slim :cards
end