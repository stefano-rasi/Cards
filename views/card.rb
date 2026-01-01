require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

class CardView < View
    draw do
        HTML.div 'card-view', ('loading' if !@html) do
            HTML.div 'button delete-button' do
                title 'delete'

                HTML.span text: 'X'

                on(:click) { on_delete(@id) }
            end

            HTML.div 'card-container' do
                html @html

                on(:click) { on_edit(@id) }
            end

            HTML.div 'binder' do
                HTML.select do
                    @binders.each do |binder|
                        binder_id = binder['id']
                        binder_name = binder['name']

                        HTML.option text: binder_name, value: binder_id do
                            selected if binder_id == @binder_id
                        end
                    end
                end

                on(:change) { |event| on_binder(@id, Native(event).target.value) }
            end

            HTML.div 'button print-button', ('not-printed' if @printed == 0), ('print-ready' if @printed == 1), ('printed' if @printed == 2) do
                case @printed
                when 0
                    title 'not printed'
                when 1
                    title 'print ready'
                when 2
                    title 'printed'
                end

                HTML.span text: 'P'

                on(:click) { on_print(@id) }
            end
        end
    end

    def initialize(id, html, printed, binder_id)
        @binders = []

        @id = id
        @html = html
        @printed = printed
        @binder_id = binder_id

        if !@html
            HTTP.get("/cards/#{id}") do |body|
                card = JSON.load(body)

                @html = card['html']

                draw
            end
        end
    end

    def binders=(binders)
        @binders = binders

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

        payload = {printed: @printed}

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