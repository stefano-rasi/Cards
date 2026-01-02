require 'lib/View/html'
require 'lib/View/view'
require 'lib/View/window'
require 'lib/View/document'

require_relative 'editor'

class ModalView < View
    draw do
        HTML.div 'modal-view' do
            HTML.div 'editor-container' do
                EditorView(@type, @text, @attributes, @binder_id) do |editor|
                    @editor = editor

                    @editor.on_close &method(:on_close)
                end
            end
        end
    end

    def initialize(type, text, attributes, binder_id)
        @type = type
        @text = text
        @binder_id = binder_id
        @attributes = attributes

        @on_mousedown = Proc.new do |event|
            event = Native(event)

            if !@editor.element.contains(event.target)
                on_close()
            end
        end

        @on_keydown = Proc.new do |event|
            event = Native(event)

            if event.key == 'Escape'
                on_close()
            end
        end

        Window.setTimeout do
            Document.addEventListener('keydown', &@on_keydown)
            Document.addEventListener('mousedown', &@on_mousedown)
        end
    end

    def focus_type()
        @editor.focus_type()
    end

    def focus_text()
        @editor.focus_text()
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
                Document.removeEventListener('mousedown', &@on_click)
            end
        end
    end
end