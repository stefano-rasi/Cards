require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

require_relative 'card'

class CardsView < View
    draw do
        HTML.div 'cards-view', ('cards-expand' if @cards_expand), ('show-binders' if @show_binders) do |div|
            @div = div

            @card_views = []

            @cards.each do |card|
                id = card['id']
                html = card['html']
                printed = card['printed']
                binder_id = card['binder_id']

                View.CardView(id, html, printed, binder_id) do |card_view|
                    @card_views << card_view

                    card_view.binders = @binders

                    card_view.on_edit(&method(:on_card_edit))
                    card_view.on_delete(&method(:on_card_delete))
                    card_view.on_binder(&method(:on_card_binder))
                end
            end

            div.style.zoom = @zoom
        end
    end

    def initialize()
        @cards = []

        @binders = []

        @card_views = []
    end

    def zoom=(zoom)
        @zoom = zoom

        @div.style.zoom = zoom
    end

    def cards=(cards)
        @cards = cards

        draw
    end

    def binders=(binders)
        @binders = binders

        @card_views.each do |card_view|
            card_view.binders = binders
        end
    end

    def cards_expand=(cards_expand)
        @cards_expand = cards_expand

        if @cards_expand
            @div.classList.add('cards-expand')
        else
            @div.classList.remove('cards-expand')
        end
    end

    def show_binders=(show_binders)
        @show_binders = show_binders

        if @show_binders
            @div.classList.add('show-binders')
        else
            @div.classList.remove('show-binders')
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