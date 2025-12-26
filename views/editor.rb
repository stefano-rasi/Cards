require 'json'

require 'lib/view/html'
require 'lib/view/http'
require 'lib/view/view'

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

                        HTTP.get('/types') do |body|
                            types = JSON.load(body)

                            types.sort.each do |type|
                                HTML.option text: type, value: type do |option|
                                    selected if type == @type

                                    @type_select.appendChild(option)
                                end
                            end
                        end
                    end
                end

                HTML.div 'attributes' do
                    HTML.input placeholder: 'attributes' do |input|
                        value @attributes

                        @attributes_input = input
                    end
                end

                HTML.div 'close-button' do
                    HTML.span text: 'X'

                    on :click, &method(:on_close)
                end
            end

            HTML.div 'text' do
                HTML.textarea do |text_textarea|
                    value @text

                    placeholder 'text'

                    @text_textarea = text_textarea

                    @text_textarea.setAttribute('spellcheck', false)
                end
            end

            HTML.div 'bottom-row' do
                HTML.div 'binder' do
                    HTML.select do |binder_select|
                        HTML.option text: 'binder', value: ''

                        @binder_select = binder_select

                        HTTP.get('/binders') do |body|
                            binders = JSON.load(body)

                            binders.each do |binder|
                                id = binder['id']
                                name = binder['name']

                                HTML.option text: name, value: id do |option|
                                    selected if id == @binder_id

                                    @binder_select.appendChild(option)
                                end
                            end
                        end
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
    end

    def on_close(&block)
        if block_given?
            @on_close_block = block
        else
            @on_close_block.call()
        end
    end

    def type
        if @type_select.value.empty?
            nil
        else
            @type_select.value
        end
    end

    def text
        @text_textarea.value
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
        @text_textarea.focus()
    end
end