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

                    @editor.on_save &method(:on_save)
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

        Window.setTimeout do
            Document.addEventListener('mousedown', &@on_mousedown)
        end
    end

    def editor
        @editor
    end

    def close()
        Document.removeEventListener('mousedown', &@on_mousedown)
    end

    def focus_type()
        @editor.focus_type()
    end

    def focus_text()
        @editor.focus_text()
    end

    def on_save(&block)
        if block_given?
            @on_save_block = block
        else
            @on_save_block.call(@editor.type, @editor.text, @editor.attributes, @editor.binder_id)
        end
    end

    def on_close(&block)
        if block_given?
            @on_close_block = block
        else
            @on_close_block.call()
        end
    end
end