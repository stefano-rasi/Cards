require 'lib/view/html'
require 'lib/view/view'

class ToolbarView < View
    draw do
        HTML.div 'toolbar-view' do
            HTML.div 'button cards-expand-button', ('selected' if @cards_expand) do
                title 'expand cards'

                HTML.span text: 'V'

                on :click, &method(:on_cards_expand)
            end

            HTML.div 'button card-new-button' do
                title 'new card'

                HTML.span text: '+'

                on :click, &method(:on_card_new)
            end
        end
    end

    def initialize()
        @cards_expand = nil
    end

    def cards_expand=(cards_expand)
        @cards_expand = cards_expand

        draw
    end

    def on_card_new(&block)
        if block_given?
            @on_card_new_block = block
        else
            @on_card_new_block.call()
        end
    end

    def on_cards_expand(&block)
        if block_given?
            @on_cards_expand_block = block
        else
            if @cards_expand
                @cards_expand = false
            else
                @cards_expand = true
            end

            draw

            @on_cards_expand_block.call()
        end
    end
end