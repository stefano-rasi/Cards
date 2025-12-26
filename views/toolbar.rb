require 'lib/view/html'
require 'lib/view/view'

class ToolbarView < View
    draw do
        HTML.div 'toolbar-view' do
            HTML.div 'left-buttons' do
                HTML.div 'button expand-button' do
                    title 'expand'

                    HTML.span text: '☰'

                    on :click, &method(:on_expand)
                end

                HTML.div 'button print-button', ('selected' if @state == :print) do
                    title 'print'

                    HTML.span text: 'P'

                    on :click, &method(:on_print)
                end
            end

            HTML.div 'right-buttons' do
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
    end

    def initialize()
        @state = nil

        @expand = nil

        @expand_cards = nil
    end

    def state=(state)
        @state = state

        draw
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

    def on_print(&block)
        if block_given?
            @on_print_block = block
        else
            @on_print_block.call()
        end
    end

    def on_binder(id, name, &block)
        if block_given?
            @on_binder_block = block
        else
            @on_binder_block.call(id, name)
        end
    end

    def on_expand(&block)
        if @expand
            @expand = false

            draw
        else
            @expand = true

            draw
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