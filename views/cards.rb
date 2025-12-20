require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

require_relative 'card'

class CardsView < View
    draw do
        HTML.div 'cards-view' do
            @card_views = []

            @cards.each do |card|
                id = card['id']

                printed = card['printed']

                binder_id = card['binder_id']

                View.CardView(id, printed, binder_id) do |card_view|
                    @card_views << card_view

                    card_view.expand = @expand

                    card_view.show_binder = @show_binder

                    card_view.on_edit(&method(:on_edit))
                    card_view.on_binder(&method(:on_binder))
                    card_view.on_delete(&method(:on_delete))
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

    def expand=(expand)
        @expand = expand

        @card_views.each do |card_view|
            card_view.expand = expand
        end
    end

    def show_binder=(show_binder)
        @show_binder = show_binder

        @card_views.each do |card_view|
            card_view.show_binder = show_binder
        end
    end

    def on_edit(id, &block)
        if block_given?
            @on_edit_block = block
        else
            @on_edit_block.call(id)
        end
    end

    def on_binder(id, binder_id, &block)
        if block_given?
            @on_binder_block = block
        else
            @on_binder_block.call(id, binder_id)
        end
    end

    def on_delete(id, &block)
        if block_given?
            @on_delete_block = block
        else
            @on_delete_block.call(id)
        end
    end
end