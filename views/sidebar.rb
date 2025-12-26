require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

class SidebarView < View
    draw do
        HTML.div 'sidebar-view', ('expanded' if @expand) do
            HTML.div 'buttons' do
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

            HTML.div 'binders' do
                @binders.each do |binder|
                    id = binder['id']
                    name = binder['name']

                    HTML.div 'binder', ('selected' if @state == :binder && id == @binder_id) do
                        text name

                        on(:click) { on_binder(id, name) }
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

            HTTP.get('/binders') do |body|
                @binders = JSON.parse(body)

                draw
            end
        end
    end
end