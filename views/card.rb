require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

class CardView < View
    draw do
        HTML.div 'card-view', ('expand' if @expand), ('loading' if !@html), ('has-binder' if @binder_id), ('show-binder' if @show_binder) do
            HTML.div 'button delete-button' do
                title 'delete'

                HTML.span text: 'X'

                on(:click) do
                    on_delete(@id)
                end
            end

            HTML.div 'card-container' do
                html @html

                on(:click) do
                    on_edit(@id)
                end
            end

            HTML.div 'binder' do
                HTML.select do
                    HTML.option text: 'binder', value: ''

                    @binders.each do |binder|
                        binder_id = binder['id']
                        binder_name = binder['name']

                        HTML.option text: binder_name, value: binder_id do
                            selected if binder_id == @binder_id
                        end
                    end
                end

                on(:change) do |event|
                    on_binder(@id, Native(event).target.value)
                end
            end

            HTML.div 'button print-button', ('not-printed' if @printed == 0), ('print-ready' if @printed == 1), ('printed' if @printed == 2) do
                title 'print'

                HTML.span text: 'P'

                on(:click) do
                    on_print(@id)
                end
            end
        end
    end

    def initialize(id, html, printed, binder_id)
        @id = id

        @html = html

        @binders = []

        @expand = false

        @printed = printed

        @binder_id = binder_id

        @show_binder = false

        if !@html
            HTTP.get("/cards/#{id}") do |body|
                card = JSON.load(body)

                @html = card['html']

                draw
            end
        end

        HTTP.get('/binders') do |body|
            binders = JSON.parse(body)

            @binders = binders

            draw
        end
    end

    def expand=(expand)
        @expand = expand

        draw
    end

    def show_binder=(show_binder)
        @show_binder = show_binder

        draw
    end

    def on_print()
        case @printed
        when 0
            @printed = 1
        when 1
            @printed = 2
        when 2
            @printed = 0
        end

        payload = { printed: @printed }

        HTTP.patch("/cards/#{@id}", payload.to_json) do
            draw
        end
    end

    def on_edit(id, &block)
        if block_given?
            @on_edit_block = block
        else
            @on_edit_block.call(id)
        end
    end

    def on_delete(id, &block)
        if block_given?
            @on_delete_block = block
        else
            @on_delete_block.call(id)
        end
    end

    def on_binder(id, binder_id, &block)
        if block_given?
            @on_binder_block= block
        else
            @on_binder_block.call(id, binder_id)
        end
    end
end