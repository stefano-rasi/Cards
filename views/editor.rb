require 'lib/view/html'
require 'lib/view/view'

require_relative 'icons'

class EditorView
    include View

    draw do
        HTML.div 'editor-view' do
            HTML.div 'top-row' do
                HTML.div 'type' do
                    @type_select = HTML.select required: true do
                        if !@card['type']
                            HTML.option text: 'type', value: '', disabled: true, selected: true
                        end

                        @types.sort.each do |type|
                            HTML.option text: type, value: type, selected: type == @card['type']
                        end
                    end
                end

                HTML.div 'attributes' do
                    @attributes_input = HTML.input placeholder: 'attributes', value: @card['attributes']
                end

                HTML.div 'close-button', title: 'close' do
                    html Icons[:close]

                    on(:click) { @on_close.call }
                end
            end

            HTML.div 'text' do
                @text_editor = HTML.textarea placeholder: 'text', value: @card['text'], spellcheck: false
            end

            HTML.div 'bottom-row' do
                HTML.div 'binder' do
                    @binder_select = HTML.select do
                        HTML.option text: 'binder', value: ''

                        @binders.each do |binder|
                            HTML.option text: binder['name'], value: binder['id'], selected: binder['id'] == @card['binder_id']
                        end
                    end
                end
            end
        end
    end

    def initialize(card, types, binders, on_close)
        @card = card
        @types = types
        @binders = binders
        @on_close = on_close
    end

    def fields
        binder_id = @binder_select.value

        {
            'type' => (@type_select.value if !@type_select.value.empty?),
            'text' => @text_editor.value,
            'binder_id' => (binder_id.to_i if !binder_id.empty?),
            'attributes' => @attributes_input.value
        }
    end

    def focus_type()
        @type_select.focus
    end

    def focus_text()
        @text_editor.focus
    end
end
