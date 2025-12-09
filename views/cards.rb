require 'opal'
require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'

require 'lib/View/document'

HTTP.get('/cards') do |body|
    cards = JSON.parse(body)

    element = CardsView.new(cards).element

    Document.body.appendChild(element)
end

class CardsView < View
    def initialize(cards)
        @cards = cards
    end

    render do
        HTML.div :cards do
            @cards.each do |card|
                HTML.div :card do |card_div|
                    data 'id', card['id']

                    HTTP.get("/cards/#{card['id']}/html") do |body|
                        card_div.innerHTML = body
                    end
                end
            end
        end
    end

    class CardView < View
        def initialize(id, type_id, text)
    end
end