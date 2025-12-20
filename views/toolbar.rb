require 'lib/view/html'
require 'lib/view/view'

class ToolbarView < View
    draw do
        HTML.div 'toolbar-view' do
            HTML.div 'button expand-cards-button', ('selected' if @expand_cards) do
                title 'expand cards'

                HTML.span text: 'V'

                on :click, &method(:on_expand_cards)
            end

            HTML.div 'button new-card-button' do
                title 'new card'

                HTML.span text: '+'

                on :click, &method(:on_new_card)
            end
        end
    end

    def initialize()
        @expand_cards = nil
    end

    def expand_cards=(expand_cards)
        @expand_cards = expand_cards

        draw
    end

    def on_new_card(&block)
        if block_given?
            @on_new_card_block = block
        else
            @on_new_card_block.call()
        end
    end

    def on_expand_cards(&block)
        if block_given?
            @on_expand_cards_block = block
        else
            if @expand_cards
                @expand_cards = false
            else
                @expand_cards = true
            end

            draw

            @on_expand_cards_block.call()
        end
    end
end