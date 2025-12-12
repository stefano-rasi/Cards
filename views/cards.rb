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

        @new_card_listener = Proc.new { |event|
            if Native(event).key == 'n'
                editor_modal = EditorModalView.new()

                editor_modal.on :close do
                    type = editor_modal.editor.type
                    text = editor_modal.editor.text

                    if !text.empty? && type.empty?
                        Window.alert('Inserire il tipo di carta')

                        false
                    else
                        if !text.empty?
                            HTTP.post('/cards', { type:, text: }.to_json) do
                                HTTP.get('/cards') do |body|
                                    cards = JSON.parse(body)

                                    @cards = cards

                                    render
                                end
                            end
                        end

                        Document.addEventListener('keyup', @new_card_listener)
                    end
                end

                Document.removeEventListener('keyup', @new_card_listener)

                Document.body.appendChild(editor_modal.element)

                editor_modal.editor.type_select.focus()
            end
        }

        Document.addEventListener('keyup', @new_card_listener)
    end

    render do
        HTML.div 'cards' do
            @cards.each do |card|
                id = card['id']

                type = card['type']
                text = card['text']

                HTML.div 'card-container' do
                    HTML.div 'card-content' do |card_div|
                        data :id, id

                        HTTP.get("/cards/#{id}/html") do |body|
                            card_div.innerHTML = body
                        end

                        on :click do |event|
                            editor_modal = EditorModalView.new(type, text)

                            Document.removeEventListener('keyup', @new_card_listener)

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

                                Document.addEventListener('keyup', @new_card_listener)
                            end

                            Document.body.appendChild(editor_modal.element)

                            editor_modal.editor.text_textarea.focus()
                        end
                    end

                    HTML.div 'delete-button', text: 'X' do
                        on :click do
                            if Window.confirm('Sei sicuro di cancellare la carta?')
                                HTTP.delete("/cards/#{id}") do
                                    HTTP.get('/cards') do |body|
                                        cards = JSON.parse(body)

                                        @cards = cards
                                    
                                        render
                                    end
                                end
                            end
                        end
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

        @key_listener = Proc.new { |event|
            if Native(event).key == 'Escape'
                if @close_block.call() != false
                    Document.body.removeChild(element)

                    Document.removeEventListener('keyup', @key_listener)
                    Document.removeEventListener('click', @click_listener)
                end
            end
        }

        @click_listener = Proc.new { |event|
            if not editor.element.contains(Native(event).target)
                if @close_block.call() != false
                    Document.body.removeChild(element)

                    Document.removeEventListener('keyup', @key_listener)
                    Document.removeEventListener('click', @click_listener)
                end
            end
        }

        Window.setTimeout do
            Document.addEventListener('keyup', @key_listener)
            Document.addEventListener('click', @click_listener)
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
            HTML.div 'editor-container' do
                EditorView(@type, @text) do |editor|
                    @editor = editor
                end

                HTML.div 'close-button', text: 'X' do
                    on :click do
                        Document.body.removeChild(element)

                        Document.removeEventListener('keyup', @key_listener)
                    end
                end
            end
        end
    end
end

HTTP.get('/cards') do |body|
    cards = JSON.parse(body)

    cards_view = CardsView.new(cards)

    Document.body.appendChild(cards_view.element)
end