require 'lib/view/html'
require 'lib/view/view'

require_relative 'card'

class CardsView
    include View

    draw do
        HTML.div 'cards-view', ('cards-expand' if @app.cards_expand?), ('show-binders' if @app.state == :home) do
            style.zoom = @app.zoom

            @app.cards.each do |card|
                CardView(@app, card)
            end
        end
    end

    def initialize(app)
        @app = app
    end
end
