require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

require_relative 'card'

class CardsView < View
    draw do
        HTML.div 'cards-view', ('cards-expand' if @cards_expand) do |div|
            @div = div

            @card_views = []

            @cards.each do |card|
                id = card['id']
                printed = card['printed']
                binder_id = card['binder_id']

                View.CardView(id, printed, binder_id) do |card_view|
                    @card_views << card_view

                    card_view.on_edit(&method(:on_card_edit))
                    card_view.on_delete(&method(:on_card_delete))
                    card_view.on_binder(&method(:on_card_binder))
                end
            end
        end
    end

    def initialize()
        @cards = []

        @card_views = []
    end

    def cards=(cards)
        @cards = cards

        draw
    end

    def cards_expand=(cards_expand)
        @cards_expand = cards_expand

        if @cards_expand
            @div.classList.add('cards-expand')
        else
            @div.classList.remove('cards-expand')
        end
    end

    def on_card_edit(id, &block)
        if block_given?
            @on_card_edit_block = block
        else
            @on_card_edit_block.call(id)
        end
    end

    def on_card_delete(id, &block)
        if block_given?
            @on_card_delete_block = block
        else
            @on_card_delete_block.call(id)
        end
    end

    def on_card_binder(id, binder_id, &block)
        if block_given?
            @on_card_binder_block = block
        else
            @on_card_binder_block.call(id, binder_id)
        end
    end
end