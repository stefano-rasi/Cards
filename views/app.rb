require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'
require 'lib/View/window'
require 'lib/View/document'

require_relative 'cards'
require_relative 'modal'
require_relative 'sidebar'
require_relative 'toolbar'

class AppView < View
    draw do
        HTML.div 'app-view' do
            HTML.div 'top-pane' do
                ToolbarView do |toolbar_view|
                    @toolbar_view = toolbar_view

                    case @state
                    when :home
                        @toolbar_view.state = :home
                    when :print
                        @toolbar_view.state = :print
                    when :binder
                        @toolbar_view.state = :binder
                    end

                    @toolbar_view.cards_expand = @cards_expand || @temporary_cards_expand
                    @toolbar_view.sidebar_expand = @sidebar_expand

                    @toolbar_view.on_home(&method(:on_home))
                    @toolbar_view.on_print(&method(:on_print))
                    @toolbar_view.on_card_new(&method(:on_card_new))
                    @toolbar_view.on_cards_expand(&method(:on_cards_expand))
                    @toolbar_view.on_sidebar_expand(&method(:on_sidebar_expand))
                end
            end

            HTML.div 'bottom-pane' do
                HTML.div 'sidebar-container' do
                    SidebarView do |sidebar_view|
                        @sidebar_view = sidebar_view

                        @sidebar_view.expand = @sidebar_expand
                        @sidebar_view.binder_id = @binder_id

                        @sidebar_view.on_binder(&method(:on_binder))
                    end
                end

                HTML.div 'cards-container' do
                    CardsView do |cards_view|
                        @cards_view = cards_view

                        @cards_view.zoom = @zoom

                        @cards_view.show_binders = @cards_show_binders
                        @cards_view.cards_expand = @cards_expand || @temporary_cards_expand

                        @cards_view.on_card_edit(&method(:on_card_edit))
                        @cards_view.on_card_delete(&method(:on_card_delete))
                        @cards_view.on_card_binder(&method(:on_card_binder))
                    end
                end
            end
        end
    end

    def initialize()
        printed_value = Document.getElementById('printed').value
        binder_id_value = Document.getElementById('binder_id').value

        @zoom = 1

        @cards_expand = false

        @sidebar_expand = true

        if !printed_value.empty?
            @state = :print

            @binder_id = nil

            @cards_show_binders = false

            @temporary_cards_expand = true
        elsif !binder_id_value.empty?
            @state = :binder

            @binder_id = binder_id_value.to_i

            @cards_show_binders = false

            @temporary_cards_expand = false
        else
            @state = :home

            @binder_id = nil

            @cards_show_binders = true

            @temporary_cards_expand = false
        end

        get_cards() do |cards|
            @cards = cards

            @cards_view.cards = cards
        end

        HTTP.get('/binders') do |body|
            binders = JSON.parse(body)

            @cards_view.binders = binders
        end

        @on_keydown = Proc.new { |event|
            on_keydown(event)
        }

        Window.addEventListener('keydown', &@on_keydown)

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

            @cards_show_binders = true

            @temporary_cards_expand = false

            @toolbar_view.state = :home
        when :print
            @binder_id = nil

            @cards_show_binders = false

            @temporary_cards_expand = true

            @toolbar_view.state = :print
        when :binder
            @cards_show_binders = false

            @temporary_cards_expand = false

            @toolbar_view.state = :binder
        end

        @sidebar_view.binder_id = @binder_id

        @toolbar_view.cards_expand = @cards_expand || @temporary_cards_expand

        get_cards() do |cards|
            @cards_view.cards = cards

            @cards_view.show_binders = @cards_show_binders

            @cards_view.cards_expand = @cards_expand || @temporary_cards_expand
        end
    end

    def get_cards(html: false, &block)
        params = {}

        case @state
        when :print
            params[:printed] = 1
        when :binder
            params[:binder_id] = @binder_id
        end

        params[:html] = true if html

        HTTP.get("/cards?#{params.map { |key, value| "#{key}=#{value}" }.join('&')}") do |body|
            cards = JSON.load(body)

            block.call(cards)
        end
    end

    def open_editor_modal(id, type, text, attributes, binder_id)
        if !id
            binder_id = @binder_id
        end

        modal = EditorModalView.new(type, text, attributes, binder_id)

        modal.on_close do |new_type, new_text, new_attributes, new_binder_id|
            if !new_type && !new_text.empty?
                Window.alert('Insert card type')

                false
            elsif !new_binder_id && !new_text.empty?
                Window.alert('Insert card binder')

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

                Window.addEventListener('keydown', &@on_keydown)

                Document.body.removeChild(modal.element)
            end
        end

        Window.removeEventListener('keydown', &@on_keydown)

        Document.body.appendChild(modal.element)

        if id
            modal.focus_text()
        else
            modal.focus_type()
        end
    end

    def on_keydown(event)
        event = Native(event)

        if !event.ctrlKey && !event.shiftKey
            case event.key
            when 'h'
                on_home()
            when 'p'
                on_print()
            when 'v'
                on_cards_expand()
            when 'e'
                on_sidebar_expand()
            when 'n'
                open_editor_modal()
            when 'r'
                get_cards() do |cards|
                    @cards_view.cards = cards
                end
            when '+'
                @zoom += 0.25

                @cards_view.zoom = @zoom
            when '-'
                @zoom -= 0.25

                @cards_view.zoom = @zoom
            end
        end
    end

    def on_home()
        state(:home)

        Window.history.pushState({state: :home}, nil, '/')
    end

    def on_print()
        state(:print)

        Window.history.pushState({state: :print}, nil, '/?printed=1')
    end

    def on_binder(id, name)
        @binder_id = id

        state(:binder)

        Window.history.pushState({state: :binder, binder_id: id}, nil, "/?binder_id=#{id}")
    end

    def on_popstate(state)
        case state[:state]
        when :home
            state(:home)
        when :print
            state(:print)
        when :binder
            @binder_id = state[:binder_id]

            state(:binder)
        end
    end

    def on_card_new()
        open_editor_modal(binder_id: @binder_id)
    end

    def on_card_edit(id)
        HTTP.get("/cards/#{id}") do |body|
            card = JSON.parse(body)

            type = card['type']
            text = card['text']

            binder_id = card['binder_id']

            attributes = card['attributes']

            open_editor_modal(id, type, text, attributes, binder_id)
        end
    end

    def on_card_binder(id, binder_id)
        HTTP.patch("/cards/#{id}", {binder_id:}.to_json) do
            get_cards(html: true) do |cards|
                @cards_view.cards = cards
            end
        end
    end

    def on_card_delete(id)
        if Window.confirm('Sei sicuro di voler cancellare la carta?')
            HTTP.delete("/cards/#{id}") do
                get_cards(html: true) do |cards|
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

    def on_sidebar_expand()
        if @sidebar_expand
            @sidebar_expand = false
        else
            @sidebar_expand = true
        end

        @sidebar_view.expand = @sidebar_expand

        @toolbar_view.sidebar_expand = @sidebar_expand
    end
end

Window.addEventListener('load') do
    app = AppView.new()

    Document.body.appendChild(app.element)
end