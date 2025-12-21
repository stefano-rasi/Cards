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
                when :home
                    @sidebar_view.state = :home
                when :print
                    @sidebar_view.state = :print
                when :binder
                    @sidebar_view.state = :binder

                    @sidebar_view.binder_id = @binder_id
                end

                @sidebar_view.expand = @expand_sidebar

                @sidebar_view.on_home(&method(:on_home))
                @sidebar_view.on_print(&method(:on_print))
                @sidebar_view.on_binder(&method(:on_binder))
            end

            HTML.div 'right-pane' do
                View.ToolbarView() do |toolbar_view|
                    @toolbar_view = toolbar_view

                    @toolbar_view.expand_cards = @expand_cards || @temporary_expand_cards

                    @toolbar_view.on_new_card(&method(:on_new_card))
                    @toolbar_view.on_expand_cards(&method(:on_expand_cards))
                end

                View.CardsView() do |cards_view|
                    @cards_view = cards_view

                    case @state
                    when :home
                        @cards_view.show_binder = true
                    else
                        @cards_view.show_binder = false
                    end

                    @cards_view.expand = @expand_cards || @temporary_expand_cards

                    @cards_view.on_edit(&method(:on_edit_card))
                    @cards_view.on_binder(&method(:on_card_binder))
                    @cards_view.on_delete(&method(:on_delete_card))
                end
            end
        end
    end

    def initialize()
        print_value = Document.getElementById('print').value
        binder_id_value = Document.getElementById('binder_id').value

        @expand_cards = false
        @expand_sidebar = true

        if !print_value.empty?
            @state = :print

            @temporary_expand_cards = true
        elsif !binder_id_value.empty?
            @state = :binder

            @binder_id = binder_id_value.to_i

            @temporary_expand_cards = false
        else
            @state = :home

            @temporary_expand_cards = false
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
        when :home
            @binder_id = nil

            @temporary_expand_cards = false

            get_cards() do |cards|
                @cards_view.cards = cards
            end

            @cards_view.show_binder = true

            @sidebar_view.state = :home
        when :print
            @binder_id = nil

            @temporary_expand_cards = true

            get_cards() do |cards|
                @cards_view.cards = cards
            end

            @cards_view.show_binder = false

            @sidebar_view.state = :print
        when :binder
            @temporary_expand_cards = false

            get_cards() do |cards|
                @cards_view.cards = cards
            end

            @cards_view.show_binder = false

            @sidebar_view.state = :binder
            @sidebar_view.binder_id = @binder_id
        end

        @cards_view.expand = @expand_cards || @temporary_expand_cards

        @toolbar_view.expand_cards = @expand_cards || @temporary_expand_cards
    end

    def get_cards(eager_html: false, &block)
        params = {}

        case @state
        when :home
            params[:binder_id] = nil
        when :print
            params[:printed] = 1
        when :binder
            params[:binder_id] = @binder_id
        end

        if eager_html
            params[:eager_html] = true
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
            if new_type.empty? and !new_text.empty?
                Window.alert('Inserire il tipo di carta')

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
                                get_cards(eager_html: true) do |cards|
                                    @cards_view.cards = cards
                                end
                            end
                        end
                    else
                        if @state == :print
                            payload[:printed] = 1
                        end

                        HTTP.post('/cards', payload.to_json) do
                            get_cards(eager_html: true) do |cards|
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
            modal.focus_text
        else
            modal.focus_type
        end
    end

    def on_home()
        state(:home)

        Window.history.pushState({ state: :home }, nil, '/')
    end

    def on_print()
        state(:print)

        Window.history.pushState({ state: :print }, nil, '/?print')
    end

    def on_keyup(event)
        event = Native(event)

        case event.key
        when 'h'
            on_home()
        when 'p'
            on_print()
        when 'n'
            open_modal()
        when 'v'
            on_expand_cards()
        end
    end

    def on_binder(id, name)
        @binder_id = id

        state(:binder)

        Window.history.pushState({ state: :binder, binder_id: id }, nil, "/?binder_id=#{id}")
    end

    def on_new_card()
        open_modal(binder_id: @binder_id)
    end

    def on_popstate(state)
        if state[:state] == :home
            state(:home)
        elsif state[:state] == :print
            state(:print)
        elsif state[:state] == :binder
            @binder_id = state[:binder_id]

            state(:binder)
        end
    end

    def on_edit_card(id)
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

    def on_delete_card(id)
        if Window.confirm('Sei sicuro di voler cancellare la carta?')
            HTTP.delete("/cards/#{id}") do
                get_cards() do |cards|
                    @cards_view.cards = cards
                end
            end
        end
    end

    def on_expand_cards()
        if @expand_cards || @temporary_expand_cards
            @expand_cards = false
        else
            @expand_cards = true
        end

        @temporary_expand_cards = false

        @cards_view.expand = @expand_cards

        @toolbar_view.expand_cards = @expand_cards
    end
end

Window.addEventListener('load') do
    app = AppView.new()

    Document.body.appendChild(app.element)
end