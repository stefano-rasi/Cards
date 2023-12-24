require 'sinatra'

require_relative 'lib/parser'

require_relative 'lib/cards/note'

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