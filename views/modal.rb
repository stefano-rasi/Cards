require 'lib/View/html'
require 'lib/View/view'
require 'lib/View/window'
require 'lib/View/document'

require_relative 'editor'

class EditorModalView < View
    render do
        HTML.div 'editor-modal-view' do
            HTML.div 'editor-container' do
                EditorView(@type, @text, @attributes, @binder_id) do |editor|
                    @editor = editor
                end

                HTML.div 'close-button' do
                    on :click, &method(:on_close)

                    HTML.span text: 'X'
                end
            end
        end
    end

    def initialize(type, text, attributes, binder_id)
        @type = type
        @text = text

        @binder_id = binder_id

        @attributes = attributes

        @on_click = Proc.new do |event|
            if !@editor.element.contains(Native(event).target)
                type = @editor.type
                text = @editor.text

                binder_id = @editor.binder_id

                attributes = @editor.attributes

                if @on_close_block.call(type, text, attributes, binder_id) != false
                    Document.removeEventListener('keyup', &@on_keyup)
                    Document.removeEventListener('click', &@on_click)
                end
            end
        end

        @on_keyup = Proc.new do |event|
            if Native(event).key == 'Escape'
                type = @editor.type
                text = @editor.text

                binder_id = @editor.binder_id

                attributes = @editor.attributes

                if @on_close_block.call(type, text, attributes, binder_id) != false
                    Document.removeEventListener('keyup', &@on_keyup)
                    Document.removeEventListener('click', &@on_click)
                end
            end
        end

        Window.setTimeout do
            Document.addEventListener('keyup', &@on_keyup)
            Document.addEventListener('click', &@on_click)
        end
    end

    def on_close(&block)
        if block_given?
            @on_close_block = block
        else
            type = @editor.type
            text = @editor.text

            binder_id = @editor.binder_id

            attributes = @editor.attributes

            if @on_close_block.call(type, text, attributes, binder_id) != false
                Document.removeEventListener('keyup', &@on_keyup)
                Document.removeEventListener('click', &@on_click)
            end
        end
    end

    def focus_type()
        @editor.focus_type()
    end

    def focus_text()
        @editor.focus_text()
    end
end