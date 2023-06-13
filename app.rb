require 'sinatra'

require_relative 'lib/parser'

require_relative 'lib/cards/latin'

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

        card_class = Card.find_class(name)

        if card_class.nil?
            nil
        else
            card_class.new(text, attributes)
        end
    }.compact

    slim :cards
end