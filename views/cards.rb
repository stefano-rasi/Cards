require 'opal'
require 'json'

require 'View/html'
require 'View/http'
require 'View/view'

require 'View/document'

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
                HTML.div :card_container do |card_container|
                    data 'id', card['id']

                    HTTP.get("/cards/#{card['id']}/html") do |body|
                        card_container.innerHTML = body
                    end
                end
            end
        end
    end
end