require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'
require 'lib/View/window'
require 'lib/View/document'

require_relative 'cards'
require_relative 'modal'
require_relative 'sidebar'

class AppView < View
    render do
        HTML.div 'app-view' do
            SidebarView(@binder_id) do |sidebar_view|
                @sidebar_view = sidebar_view

                @sidebar_view.on_home do
                    on_home()
                end

                @sidebar_view.on_print do
                    on_print()
                end

                @sidebar_view.on_change do |binder_id, binder_name|
                    on_change(binder_id, binder_name)
                end
            end

            HTML.div 'right-pane' do
                HTML.div 'toolbar' do
                    HTML.div 'button view-button' do
                        HTML.span text: 'V'

                        on :click do
                            on_view()
                        end
                    end

                    HTML.div 'button new-button' do
                        HTML.span text: '+'

                        on :click do
                            open_modal()
                        end
                    end
                end

                CardsView() do |cards_view|
                    @cards_view = cards_view

                    @cards_view.on_edit do |id|
                        on_edit(id)
                    end

                    @cards_view.on_delete do |id|
                        on_delete(id)
                    end
                end
            end
        end
    end

    def initialize()
        @full_height = false

        binder_id = Document.getElementById('binder_id').value

        if !binder_id.empty?
            @binder_id = binder_id.to_i
        else
            @binder_id = nil
        end

        is_printed = Document.getElementById('is_printed').value

        if !is_printed.empty?
            @is_printed = is_printed.to_i
        else
            @is_printed = nil
        end

        HTTP.get('/binders') do |binders_body|
            binders = JSON.load(binders_body)

            @cards_view.binders = binders

            @cards_view.show_binders = true

            get_cards() do |cards|
                if @binder_id || @is_printed
                    @cards_view.show_binders = false
                end

                @cards_view.cards = cards

                @cards_view.render
            end
        end

        @on_keyup = Proc.new do |event|
            on_keyup(event)
        end

        Window.addEventListener('keyup', &@on_keyup)
    end

    def on_home()
        @binder_id = nil

        @is_printed = nil

        @sidebar_view.binder_id = @binder_id

        @sidebar_view.render

        get_cards() do |cards|
            @cards_view.cards = cards

            @cards_view.full_height = @full_height

            @cards_view.show_binders = true

            @cards_view.render
        end

        Window.history.pushState(nil, '', '/')
    end

    def on_edit(id)
        HTTP.get("/cards/#{id}") do |body|
            card = JSON.parse(body)

            type = card['type']
            text = card['text']

            binder_id = card['binder_id']

            attributes = card['attributes']

            open_modal(id, type, text, attributes, binder_id)
        end
    end

    def on_view()
        if @full_height
            @full_height = false
        else
            @full_height = true
        end

        @cards_view.full_height = @full_height
    end

    def on_print()
        @binder_id = nil

        @is_printed = 1

        @sidebar_view.binder_id = nil

        @sidebar_view.render

        get_cards() do |cards|
            @cards_view.cards = cards

            @cards_view.full_height = true

            @cards_view.show_binders = false

            @cards_view.render
        end

        Window.history.pushState(nil, '', "/?is_printed=#{@is_printed}")
    end

    def on_change(binder_id, binder_name)
        @binder_id = binder_id

        @is_printed = nil

        get_cards() do |cards|
            @cards_view.cards = cards

            @cards_view.full_height = @full_height

            @cards_view.show_binders = false

            @cards_view.render
        end

        Window.history.pushState(@binder_id, '', "/?binder=#{binder_name}")
    end

    def on_delete(id)
        get_cards() do |cards|
            @cards_view.cards = cards

            @cards_view.render
        end
    end

    def on_keyup(event)
        case Native(event).key
        when 'h'
            on_home()
        when 'v'
            on_view()
        when 'p'
            on_print()
        when 'n'
            open_modal()
        end
    end

    def get_cards(&block)
        HTTP.get("/cards?binder_id=#{@binder_id}&is_printed=#{@is_printed}") do |body|
            cards = JSON.load(body)

            block.call(cards)
        end
    end

    def open_modal(id, type, text, attributes, binder_id)
        modal = EditorModalView.new(type, text, attributes, binder_id)

        modal.on_close do |type, text, attributes, binder_id|
            if type.empty? and !text.empty?
                Window.alert('Inserire il tipo')

                false
            else
                if !text.empty?
                    payload = { type:, text:, attributes:, binder_id:, is_printed: 0 }

                    if id
                        HTTP.put("/cards/#{id}", payload.to_json) do
                            binder_id = @sidebar_view.binder_id

                            HTTP.get("/cards?binder_id=#{binder_id}") do |body|
                                cards = JSON.parse(body)

                                @cards_view.cards = cards

                                @cards_view.render
                            end
                        end
                    else
                        HTTP.post('/cards', payload.to_json) do
                            binder_id = @sidebar_view.binder_id

                            HTTP.get("/cards?binder_id=#{binder_id}") do |body|
                                cards = JSON.parse(body)

                                @cards_view.cards = cards

                                @cards_view.render
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

        if text
            modal.focus_text()
        else
            modal.focus_type()
        end
    end
end

Window.addEventListener('load') do
    app = AppView.new()

    Document.body.appendChild(app.element)
end