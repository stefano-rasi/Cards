require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

class SidebarView < View
    draw do
        HTML.div 'sidebar-view', ('expanded' if @expand) do
            HTML.div 'first-row' do
                HTML.div 'button expand-button' do
                    title 'expand'

                    HTML.span text: '☰'

                    on :click, &method(:on_expand)
                end

                HTML.div 'buttons' do
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
            end

            HTML.div 'binders' do
                @binders.each do |binder|
                    binder_id = binder['id']
                    binder_name = binder['name']

                    HTML.div 'binder-container' do
                        HTML.div 'binder', ('selected' if @state == :binder && binder_id == @binder_id && !@divider_id) do
                            if binder_id == @binder_id
                                HTML.span 'icon', text: '▼'
                            else
                                HTML.span 'icon', text: '▶'
                            end

                            HTML.span 'name', text: binder_name

                            on(:click) do
                                on_binder(binder_id)
                            end
                        end

                        if binder_id == @binder_id
                            HTML.div 'dividers' do
                                binder['dividers'].each do |divider|
                                    divider_id = divider['id']
                                    divider_name = divider['name']

                                    HTML.div 'divider', ('color' if divider_name.start_with? 'hsl'), ('selected' if @state == :binder && divider_id == @divider_id) do
                                        HTML.div 'name' do
                                            if divider_name.start_with? 'hsl'
                                                style.color = divider_name
                                                style.backgroundColor = divider_name
                                            else
                                                text divider_name
                                            end
                                        end

                                        on(:click) do
                                            on_binder(binder_id, divider_id)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    def initialize()
        @state = nil

        @expand = nil

        @binders = []

        @binder_id = nil

        HTTP.get('/binders') do |body|
            @binders = JSON.parse(body)

            draw
        end
    end

    def state=(state)
        @state = state

        draw
    end

    def expand=(expand)
        @expand = expand

        draw
    end

    def binder_id=(binder_id)
        @binder_id = binder_id

        draw
    end

    def divider_id=(divider_id)
        @divider_id = divider_id

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

    def on_binder(binder_id, divider_id, &block)
        if block_given?
            @on_binder_block = block
        else
            @on_binder_block.call(binder_id, divider_id)
        end
    end

    def on_expand(&block)
        if @expand
            @expand = false

            draw
        else
            @expand = true

            HTTP.get('/binders') do |body|
                @binders = JSON.parse(body)

                draw
            end
        end
    end
end