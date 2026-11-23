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

class AppView
    include View

    attr_reader :zoom
    attr_reader :state
    attr_reader :cards
    attr_reader :types
    attr_reader :binders
    attr_reader :binder_id
    attr_reader :sidebar_expand

    draw do
        HTML.div 'app-view' do
            HTML.div 'top-pane' do
                ToolbarView(self) { |view| @toolbar_view = view }
            end

            HTML.div 'bottom-pane' do
                HTML.div 'sidebar-container' do
                    SidebarView(self) { |view| @sidebar_view = view }
                end

                HTML.div 'cards-container' do
                    CardsView(self) { |view| @cards_view = view }
                end
            end
        end
    end

    def initialize()
        @zoom = 1

        @cards = []
        @types = []
        @binders = []

        @cards_expand = false
        @sidebar_expand = true

        printed = Document.getElementById('printed').value
        binder_id = Document.getElementById('binder_id').value

        if !printed.empty?
            show(:print, printed: printed.to_i)
        elsif !binder_id.empty?
            show(:binder, binder_id: binder_id.to_i)
        else
            show(:home)
        end

        Window.history.replaceState(history_state, nil)

        HTTP.get('/types') do |types|
            @types = types
        end

        HTTP.get('/binders') do |binders|
            @binders = binders

            refresh
        end

        Window.addEventListener('keydown') { |event| on_keydown(Native(event)) }
        Window.addEventListener('popstate') { |event| on_popstate(Native(event).state) }
    end

    def refresh()
        return if !@element

        @toolbar_view.draw
        @sidebar_view.draw
        @cards_view.draw
    end

    def cards_expand?
        @cards_expand || @temporary_cards_expand
    end

    def show(state, binder_id: nil, printed: 1)
        @state = state
        @printed = printed
        @binder_id = binder_id

        @temporary_cards_expand = state == :print

        load_cards
    end

    def go(state, binder_id: nil)
        show(state, binder_id: binder_id)

        url = {home: '/', print: '/?printed=1', binder: "/?binder_id=#{binder_id}"}[state]

        Window.history.pushState(history_state, nil, url)
    end

    def history_state
        {state: @state, binder_id: @binder_id, printed: @printed}
    end

    def load_cards()
        case @state
        when :print
            url = "/cards?printed=#{@printed}"
        when :binder
            url = "/cards?binder_id=#{@binder_id}"
        else
            url = '/cards'
        end

        @cards_url = url

        HTTP.get(url) do |cards|
            next if url != @cards_url

            @cards = cards

            refresh
        end
    end

    def home()
        go(:home)
    end

    def print()
        go(:print)
    end

    def binder(id)
        go(:binder, binder_id: id)
    end

    def toggle_sidebar()
        @sidebar_expand = !@sidebar_expand

        refresh
    end

    def toggle_cards_expand()
        @cards_expand = !cards_expand?

        @temporary_cards_expand = false

        refresh
    end

    def zoom_by(amount)
        @zoom += amount

        refresh
    end

    def new_card()
        open_editor({'binder_id' => @binder_id})
    end

    def edit_card(card)
        open_editor(card)
    end

    def open_editor(card)
        @modal = ModalView.new(self, card)

        Document.body.appendChild(@modal.element)

        @modal.open
    end

    def close_editor(card, fields)
        if !fields['text'].empty?
            if !fields['type']
                Window.alert('Insert card type')

                return false
            end

            if !fields['binder_id']
                Window.alert('Insert card binder')

                return false
            end

            save_card(card, fields)
        end

        @modal.element.remove

        @modal = nil

        true
    end

    def save_card(card, fields)
        if card['id']
            if fields.any? { |key, value| card[key] != value }
                HTTP.patch("/cards/#{card['id']}", fields.to_json) { load_cards }
            end
        else
            fields['printed'] = 1 if @state == :print

            HTTP.post('/cards', fields.to_json) { load_cards }
        end
    end

    def move_card(card, binder_id)
        HTTP.patch("/cards/#{card['id']}", {binder_id: binder_id}.to_json) { load_cards }
    end

    def delete_card(card)
        if Window.confirm('Sei sicuro di voler cancellare la carta?')
            HTTP.delete("/cards/#{card['id']}") { load_cards }
        end
    end

    def print_card(card)
        card['printed'] = (card['printed'] + 1) % 3

        HTTP.patch("/cards/#{card['id']}", {printed: card['printed']}.to_json) { refresh }
    end

    def on_keydown(event)
        return if @modal || event.ctrlKey || event.shiftKey

        case event.key
        when '+'
            zoom_by(0.25)
        when '-'
            zoom_by(-0.25)
        when 'e'
            toggle_sidebar()
        when 'h'
            home()
        when 'n'
            new_card()
        when 'p'
            print()
        when 'r'
            load_cards()
        when 'v'
            toggle_cards_expand()
        end
    end

    def on_popstate(state)
        return if !state

        show(state[:state].to_sym, binder_id: state[:binder_id], printed: state[:printed])
    end
end

Window.addEventListener('load') do
    app = AppView.new()

    Document.body.appendChild(app.element)
end
