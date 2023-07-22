require 'sinatra'

require_relative 'lib/parser'

require_relative 'lib/cards/note'
require_relative 'lib/cards/latin'
require_relative 'lib/cards/music'
require_relative 'lib/cards/japanese'
require_relative 'lib/cards/random_table'

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