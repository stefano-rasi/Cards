require 'sinatra'

require_relative 'lib/card'

require_relative 'lib/cards/note'
require_relative 'lib/cards/study'
require_relative 'lib/cards/recipe'
require_relative 'lib/cards/italian'
require_relative 'lib/cards/japanese'

get '/cards/*' do
    path = "cards/#{params[:splat][0]}"

    @cards = CardsParser.new.parse(File.read(path)).map { |card|
        if card_class = Card.classes[card[:name]]
            card_class.new(card[:text], card[:attributes])
        end
    }.compact

    slim :cards
end

class CardsParser
    INDENT = 2

    def parse(text)
        cards = []

        text.split("\n").each do |line|
            indent = line[/^\s*/].size

            if indent == 0 && !line.empty?
                name = line[/^[^\s:]+/]

                attributes = line.sub(/^[^\s:]+\s*/, '').sub(/\s*:$/, '').split(/\s+/).map do |attribute|
                    name, value = attribute.split('=')

                    { name:, value: }
                end

                cards << {
                    text: '',
                    name: name,
                    attributes: attributes,
                }
            elsif not cards.empty?
                cards[-1][:text] += line.sub(/^ {#{INDENT}}/, '') + "\n"
            end
        end

        cards
    end
end