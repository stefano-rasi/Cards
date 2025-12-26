require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'
require 'lib/view/window'
require 'lib/view/document'

require_relative 'cards'
require_relative 'modal'
require_relative 'sidebar'
require_relative 'toolbar'

class AppView < View
    draw do
        HTML.div 'app-view' do
            View.SidebarView() do |sidebar_view|
                @sidebar_view = sidebar_view

                case @state
                when :print
                    @sidebar_view.state = :print
                when :binder
                    @sidebar_view.state = :binder

                    @sidebar_view.binder_id = @binder_id
                end

                @sidebar_view.expand = @sidebar_expand

                @sidebar_view.on_print(&method(:on_print))
                @sidebar_view.on_binder(&method(:on_binder))
            end

            HTML.div 'right-pane' do
                View.ToolbarView() do |toolbar_view|
                    @toolbar_view = toolbar_view

                    @toolbar_view.cards_expand = @cards_expand || @temporary_cards_expand

                    @toolbar_view.on_card_new(&method(:on_card_new))
                    @toolbar_view.on_cards_expand(&method(:on_cards_expand))
                end

                View.CardsView() do |cards_view|
                    @cards_view = cards_view

                    @cards_view.cards_expand = @cards_expand || @temporary_cards_expand

                    @cards_view.on_card_edit(&method(:on_card_edit))
                    @cards_view.on_card_delete(&method(:on_card_delete))
                    @cards_view.on_card_binder(&method(:on_card_binder))
                end
            end
        end
    end

    def initialize()
        printed_value = Document.getElementById('printed').value
        binder_id_value = Document.getElementById('binder_id').value

        @cards_expand = false
        @sidebar_expand = true

        if !printed_value.empty?
            @state = :print

            @temporary_cards_expand = true
        elsif !binder_id_value.empty?
            @state = :binder

            @binder_id = binder_id_value.to_i

            @temporary_cards_expand = false
        end

        get_cards() do |cards|
            @cards = cards

            @cards_view.cards = cards
        end

        @on_keyup = Proc.new { |event|
            on_keyup(event)
        }

        Window.addEventListener('keyup', &@on_keyup)

        Window.addEventListener('popstate') do |event|
            event = Native(event)

            on_popstate(event.state)
        end
    end

    def state(state)
        @state = state

        case @state
        when :print
            @binder_id = nil

            @temporary_cards_expand = true

            get_cards() do |cards|
                @cards_view.cards = cards
            end

            @sidebar_view.state = :print
        when :binder
            @temporary_cards_expand = false

            get_cards() do |cards|
                @cards_view.cards = cards
            end

            @sidebar_view.state = :binder

            @sidebar_view.binder_id = @binder_id
        end

        @cards_view.cards_expand = @cards_expand || @temporary_cards_expand

        @toolbar_view.cards_expand = @cards_expand || @temporary_cards_expand
    end

    def get_cards(html: false, &block)
        params = {}

        case @state
        when :print
            params[:printed] = 1
        when :binder
            params[:binder_id] = @binder_id
        end

        if html
            params[:html] = true
        end

        HTTP.get("/cards?#{params.map { |key, value| "#{key}=#{value}" }.join('&')}") do |body|
            cards = JSON.load(body)

            block.call(cards)
        end
    end

    def open_modal(id, type, text, attributes, binder_id)
        if !id
            binder_id = @binder_id
        end

        modal = EditorModalView.new(type, text, attributes, binder_id)

        modal.on_close do |new_type, new_text, new_attributes, new_binder_id|
            if !new_type && !new_text.empty?
                Window.alert('Inserire il tipo di carta')

                false
            elsif !new_binder_id && !new_text.empty?
                Window.alert('Inserire il raccoglitore')

                false
            else
                if !new_text.empty?
                    payload = {
                        type: new_type,
                        text: new_text,
                        binder_id: new_binder_id,
                        attributes: new_attributes
                    }

                    if id
                        if new_text != text || new_type != type || new_binder_id != binder_id || new_attributes != attributes
                            HTTP.patch("/cards/#{id}", payload.to_json) do
                                get_cards(html: true) do |cards|
                                    @cards_view.cards = cards
                                end
                            end
                        end
                    else
                        if @state == :print
                            payload[:printed] = 1
                        end

                        HTTP.post('/cards', payload.to_json) do
                            get_cards(html: true) do |cards|
                                @cards_view.cards = cards
                            end
                        end
                    end
                end

                Window.addEventListener('keyup', &@on_keyup)

                Document.body.removeChild(modal.element)
            end
        end

        Window.removeEventListener('keyup', &@on_keyup)

        Document.body.appendChild(modal.element)

        if id
            modal.focus_text()
        else
            modal.focus_type()
        end
    end

    def on_print()
        state(:print)

        Window.history.pushState({ state: :print }, nil, '/?printed=1')
    end

    def on_keyup(event)
        event = Native(event)

        case event.key
        when 'p'
            on_print()
        when 'n'
            open_modal()
        when 'v'
            on_cards_expand()
        end
    end

    def on_binder(id, name)
        @binder_id = id

        state(:binder)

        Window.history.pushState({ state: :binder, binder_id: id }, nil, "/?binder_id=#{id}")
    end

    def on_popstate(state)
        if state[:state] == :print
            state(:print)
        elsif state[:state] == :binder
            @binder_id = state[:binder_id]

            state(:binder)
        end
    end

    def on_card_new()
        open_modal(binder_id: @binder_id)
    end

    def on_card_edit(id)
        HTTP.get("/cards/#{id}") do |body|
            card = JSON.parse(body)

            type = card['type']
            text = card['text']

            binder_id = card['binder_id']

            attributes = card['attributes']

            open_modal(id, type, text, attributes, binder_id)
        end
    end

    def on_card_binder(id, binder_id)
        HTTP.patch("/cards/#{id}", { binder_id: }.to_json) do
            get_cards() do |cards|
                @cards_view.cards = cards
            end
        end
    end

    def on_card_delete(id)
        if Window.confirm('Sei sicuro di voler cancellare la carta?')
            HTTP.delete("/cards/#{id}") do
                get_cards() do |cards|
                    @cards_view.cards = cards
                end
            end
        end
    end

    def on_cards_expand()
        if @cards_expand || @temporary_cards_expand
            @cards_expand = false
        else
            @cards_expand = true
        end

        @temporary_cards_expand = false

        @cards_view.cards_expand = @cards_expand

        @toolbar_view.cards_expand = @cards_expand
    end
end

Window.addEventListener('load') do
    app = AppView.new()

    Document.body.appendChild(app.element)
end