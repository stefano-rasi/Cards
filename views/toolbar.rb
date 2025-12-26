require 'lib/view/html'
require 'lib/view/view'

class ToolbarView < View
    draw do
        HTML.div 'toolbar-view' do
            HTML.div 'left-buttons' do
                HTML.div 'button sidebar-expand-button', ('selected' if @sidebar_expand) do
                    title 'expand sidebar'

                    HTML.span text: '☰'

                    on :click, &method(:on_sidebar_expand)
                end

                HTML.div 'button home-button', ('selected' if @state == :home) do
                    title 'home'

                    HTML.span text: 'H'

                    on :click, &method(:on_home)
                end

                HTML.div 'button print-button', ('selected' if @state == :print) do
                    title 'print'

                    HTML.span text: 'P'

                    on :click, &method(:on_print)
                end
            end

            HTML.div 'right-buttons' do
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
    end

    def initialize()
        @state = nil

        @cards_expand = nil

        @sidebar_expand = nil
    end

    def state=(state)
        @state = state

        draw
    end

    def cards_expand=(cards_expand)
        @cards_expand = cards_expand

        draw
    end

    def sidebar_expand=(sidebar_expand)
        @sidebar_expand = sidebar_expand

        draw
    end

    def on_home(&block)
        if block_given?
            @on_home_block = block
        else
            @on_home_block.call()
        end
    end

    def on_print(&block)
        if block_given?
            @on_print_block = block
        else
            @on_print_block.call()
        end
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

    def on_sidebar_expand(&block)
        if block_given?
            @on_sidebar_expand_block = block
        else
            if @sidebar_expand
                @sidebar_expand = false
            else
                @sidebar_expand = true
            end

            draw

            @on_sidebar_expand_block.call()
        end
    end

end