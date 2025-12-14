require 'opal'
require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'
require 'lib/View/window'
require 'lib/View/document'

class CardsView < View
    render do
        HTML.div 'cards-view' do |div|
            @div = div

            if @full_height
                @div.classList.add('full-height')
            end

            if @show_binders
                @div.classList.add('show-binders')
            end

            @cards.each do |card|
                card_id = card['id']

                is_printed = card['is_printed']

                card_binder_id = card['binder_id']

                HTML.div 'card-container' do
                    data :id, card_id

                    HTML.div 'card-content' do |container|
                        on :click do
                            @on_edit_block.call(card_id)
                        end

                        HTTP.get("/cards/#{card_id}/html") do |body|
                            container.innerHTML = body
                        end
                    end

                    HTML.div 'binder' do |binder_div|
                        HTML.select do |binder_select|
                            HTML.option text: 'binder', value: ''

                            on :change do
                                binder_id = binder_select.value

                                HTTP.patch("/cards/#{card_id}", { binder_id: }.to_json)

                                if !binder_id.empty?
                                    binder_div.classList.add('has_binder')
                                else
                                    binder_div.classList.remove('has_binder')
                                end
                            end

                            if !@binders.empty?
                                @binders.each do |binder|
                                    binder_id = binder['id']
                                    binder_name = binder['name']

                                    HTML.option text: binder_name, value: binder_id do |option|
                                        if binder_id == card_binder_id
                                            selected

                                            binder_div.classList.add('has_binder')
                                        end

                                        binder_select.appendChild(option)
                                    end
                                end
                            else
                                HTTP.get('/binders') do |body|
                                    @binders = JSON.load(body)

                                    @binders.each do |binder|
                                        binder_id = binder['id']
                                        binder_name = binder['name']

                                        HTML.option text: binder_name, value: binder_id do |option|
                                            if binder_id == card_binder_id
                                                selected

                                                binder_div.classList.add('has_binder')
                                            end

                                            binder_select.appendChild(option)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    HTML.div 'button print-button' do |button|
                        HTML.span text: 'P'

                        case is_printed
                        when 0
                            button.classList.add('not-printed')
                        when 1
                            button.classList.add('not-printed')
                            button.classList.add('print-ready')
                        end

                        on :click do
                            case is_printed
                            when 0
                                is_printed = 1

                                button.classList.add('print-ready')
                            when 1
                                is_printed = 2

                                button.classList.remove('not-printed')
                                button.classList.remove('print-ready')
                            when 2
                                is_printed = 0

                                button.classList.add('not-printed')
                            end

                            HTTP.patch("/cards/#{card_id}", { is_printed: }.to_json)
                        end
                    end

                    HTML.div 'button delete-button' do
                        HTML.span text: 'X'

                        on :click do
                            if Window.confirm('Sei sicuro di voler cancellare la carta?')
                                HTTP.delete("/cards/#{card_id}") do
                                    @on_delete_block.call(card_id)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    def initialize(cards)
        if cards
            @cards = cards
        else
            @cards = []
        end

        @binders = []

        @show_binders = true
    end

    def cards=(cards)
        @cards = cards
    end

    def binders=(binders)
        @binders = binders
    end

    def on_edit(&block)
        @on_edit_block = block
    end

    def on_delete(&block)
        @on_delete_block = block
    end

    def full_height=(full_height)
        @full_height = full_height

        if @full_height
            @div.classList.add('full-height')
        else
            @div.classList.remove('full-height')
        end
    end

    def show_binders=(show_binders)
        @show_binders = show_binders
    end
end