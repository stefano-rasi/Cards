require 'opal'

require 'json'

require 'lib/View/html'
require 'lib/View/view'

class EditorView < View
    def initialize(type, text, attributes, binder_id, section_id)
        @type = type
        @text = text

        @binder_id = binder_id
        @section_id = section_id

        @attributes = attributes
    end

    def text
        @text_textarea.value
    end

    def type
        @type_selector.type
    end

    def binder_id
        @binder_selector.id
    end

    def section_id
        @section_selector.id
    end

    def type_select
        @type_selector.select
    end

    def text_textarea
        @text_textarea
    end

    render do
        HTML.div 'editor' do
            HTML.div 'row' do
                BinderSelectorView(@binder_id) do |binder_selector|
                    @binder_selector = binder_selector
                end

                SectionSelectorView(@section_id) do |section_selector|
                    @section_selector = section_selector
                end
            end

            HTML.div 'row' do
                TypeSelectorView(@type) do |type_selector|
                    @type_selector = type_selector
                end

                HTML.div 'attributes' do
                    HTML.input placeholder: 'attributes'
                end
            end

            HTML.div 'text' do
                HTML.textarea do |text_textarea|
                    value @text

                    placeholder 'text'

                    @text_textarea = text_textarea

                    text_textarea.setAttribute('spellcheck', false)
                end
            end
        end
    end

    class TypeSelectorView < View
        def initialize(type)
            @type = type

            HTTP.get('/types') do |body|
                types = JSON.load(body)

                types.sort.each do |type|
                    HTML.option text: type, value: type do |option|
                        selected if type == @type

                        @select.appendChild(option)
                    end
                end
            end
        end

        def type
            @select.value
        end

        def select
            @select
        end

        render do
            HTML.div 'type' do
                HTML.select do |select|
                    required

                    if not @type
                        HTML.option text: 'type', value: '', disabled: true, selected: true
                    end

                    @select = select
                end
            end
        end
    end

    class BinderSelectorView < View
        def initialize(id)
            @id = id
        end

        def id
            @id
        end

        render do
            HTML.div 'binder' do
                HTML.select do |select|
                    required

                    if not @id
                        HTML.option text: 'binder', value: '', disabled: true, selected: true
                    end

                    @select = select
                end
            end
        end
    end

    class SectionSelectorView < View
        def initialize(id)
            @id = id
        end

        def id
            @id
        end

        render do
            HTML.div 'binder' do
                HTML.select do |select|
                    required

                    if not @id
                        HTML.option text: 'section', value: '', disabled: true, selected: true
                    end

                    @select = select
                end
            end
        end
    end
end