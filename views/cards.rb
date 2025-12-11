require 'opal'
require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'

require 'lib/View/window'
require 'lib/View/document'

require_relative 'editor'

class CardsView < View
    def initialize(cards)
        @cards = cards

        Document.addEventListener('keyup') do |event|
            if Native(event).key == 'n'
                editor_modal = EditorModalView.new()

                editor_modal.on :close do
                    type = editor_modal.editor.type
                    text = editor_modal.editor.text

                    if not text.empty?
                        HTTP.post('/cards', { type:, text: }.to_json) do
                            HTTP.get('/cards') do |body|
                                cards = JSON.parse(body)

                                @cards = cards

                                render
                            end
                        end
                    end
                end

                Document.body.appendChild(editor_modal.element)

                editor_modal.editor.textarea.focus()
            end
        end
    end

    render do
        HTML.div 'cards' do
            @cards.each do |card|
                HTML.div 'card-container' do |card_div|
                    id = card['id']

                    data :id, id

                    HTTP.get("/cards/#{id}/html") do |body|
                        card_div.innerHTML = body
                    end

                    type = card['type']
                    text = card['text']

                    on :click do |event|
                        editor_modal = EditorModalView.new(type, text)

                        editor_modal.on :close do
                            type = editor_modal.editor.type
                            text = editor_modal.editor.text

                            HTTP.put("/cards/#{id}", { id:, type:, text: }.to_json) do
                                HTTP.get('/cards') do |body|
                                    cards = JSON.parse(body)

                                    @cards = cards
                                    
                                    render
                                end
                            end
                        end

                        Document.body.appendChild(editor_modal.element)

                        editor_modal.editor.textarea.focus()
                    end

                end
            end
        end
    end
end

class EditorModalView < View
    def initialize(type, text)
        @type = type
        @text = text

        key_listener = nil
        click_listener = nil

        key_listener = Proc.new do |event|
            if Native(event).key == 'Escape'
                @close_block.call()

                Document.body.removeChild(element)

                Document.removeEventListener('keyup', key_listener)
                Document.removeEventListener('click', click_listener)
            end
        end

        click_listener = Proc.new do |event|
            if not editor.element.contains(Native(event).target)
                @close_block.call()

                Document.body.removeChild(element)

                Document.removeEventListener('keyup', key_listener)
                Document.removeEventListener('click', click_listener)
            end
        end

        Window.setTimeout do
            Document.addEventListener('keyup', key_listener)
            Document.addEventListener('click', click_listener)
        end
    end

    def on(type, &block)
        if type == :close
            @close_block = block
        end
    end

    def editor
        @editor
    end

    render do
        HTML.div 'editor-modal' do
            EditorView(@type, @text) do |editor|
                @editor = editor
            end
        end
    end
end

HTTP.get('/cards') do |body|
    cards = JSON.parse(body)

    cards_view = CardsView.new(cards)

    Document.body.appendChild(cards_view.element)
end