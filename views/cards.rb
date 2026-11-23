require 'lib/view/html'
require 'lib/view/view'

require_relative 'card'

class CardsView
    include View

    draw do
        HTML.div 'cards-view' do |element|
            @app.cards.each do |card|
                CardView(@app, card)
            end

            layout(element)
        end
    end

    def initialize(app)
        @app = app
    end

    def layout(element = self.element)
        element.classList.toggle('cards-expand', @app.cards_expand?)

        element.style.zoom = @app.zoom
    end
end
