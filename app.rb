require 'sinatra'

require_relative 'lib/parser'

require_relative 'lib/cards/note'
require_relative 'lib/cards/latin'
require_relative 'lib/cards/music'
require_relative 'lib/cards/table'
require_relative 'lib/cards/japanese'

get '/cards/*' do
    path = "cards/#{params[:splat][0]}"

    cards = CardsParser.new.parse(File.read(path))

    @cards = cards.map { |card|
        tag = card[:tag]

        attributes = tag[:attributes].map { |attribute|
            key = String(attribute[:key])
            value = String(attribute[:value])

            [ key, value ]
        }.to_h

        name = String(tag[:name])
        text = String(card[:text])

        klass = Card.descendant(name)

        if klass.nil?
            nil
        else
            klass.new(text, attributes)
        end
    }.compact

    slim :cards
end