require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'

class EditorView < View
    draw do
        HTML.div 'editor-view' do
            HTML.div 'top-row' do
                HTML.div 'type' do
                    HTML.select do |type_select|
                        required

                        if !@type
                            HTML.option text: 'type', value: '', disabled: true, selected: true
                        end

                        @type_select = type_select
                    end
                end

                HTML.div 'attributes' do
                    HTML.input placeholder: 'attributes' do |input|
                        value @attributes

                        @attributes_input = input
                    end
                end

                HTML.div 'close-button' do
                    title 'close'

                    HTML.span text: 'X'

                    on :click, &method(:on_close)
                end
            end

            HTML.div 'text' do
                HTML.textarea do |text_editor|
                    value @text

                    attribute 'spellcheck', false

                    placeholder 'text'

                    @text_editor = text_editor
                end
            end

            HTML.div 'bottom-row' do
                HTML.div 'binder' do
                    HTML.select do |binder_select|
                        HTML.option text: 'binder', value: ''

                        @binder_select = binder_select
                    end
                end
            end
        end
    end

    def initialize(type, text, attributes, binder_id)
        @type = type
        @text = text
        @binder_id = binder_id
        @attributes = attributes

        HTTP.get('/types') do |body|
            types = JSON.load(body)

            types.sort.each do |type|
                HTML.option text: type, value: type do |option|
                    selected if type == @type

                    @type_select.appendChild(option)
                end
            end
        end

        HTTP.get('/binders') do |body|
            binders = JSON.load(body)

            binders.each do |binder|
                binder_id = binder['id']
                binder_name = binder['name']

                HTML.option text: binder_name, value: binder_id do |option|
                    selected if binder_id == @binder_id

                    @binder_select.appendChild(option)
                end
            end
        end
    end

    def text
        @text_editor.value
    end

    def type
        if @type_select.value.empty?
            nil
        else
            @type_select.value
        end
    end

    def binder_id
        if @binder_select.value.empty?
            nil
        else
            @binder_select.value.to_i
        end
    end

    def attributes
        @attributes_input.value
    end

    def focus_type()
        @type_select.focus()
    end

    def focus_text()
        @text_editor.focus()
    end

    def on_close(&block)
        if block_given?
            @on_close_block = block
        else
            @on_close_block.call()
        end
    end
end