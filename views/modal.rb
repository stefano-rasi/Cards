require 'lib/view/html'
require 'lib/view/view'

require_relative 'editor'

class ModalView
    include View

    draw do
        HTML.dialog 'modal-view' do
            EditorView(@card, @app.types, @app.binders, method(:close)) { |editor| @editor = editor }

            on(:keydown) do |event|
                event = Native(event)

                if event.key == 'Escape'
                    event.preventDefault

                    close
                end
            end

            on(:click) do |event|
                event = Native(event)

                close if event.target == event.currentTarget
            end
        end
    end

    def initialize(app, card)
        @app = app
        @card = card
    end

    def open()
        element.showModal

        if @card['id']
            @editor.focus_text
        else
            @editor.focus_type
        end
    end

    def close()
        @app.close_editor(@card, @editor.fields)
    end
end
