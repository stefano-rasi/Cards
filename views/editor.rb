require 'opal'

require 'json'

require 'lib/View/html'
require 'lib/View/view'

class EditorView < View
    def initialize(type, text)
        @type = type
        @text = text
    end

    def text
        @text_textarea.value
    end

    def type
        @type_selector.type
    end

    def type_select
        @type_selector.select
    end

    def text_textarea
        @text_textarea
    end

    render do
        HTML.div 'editor' do
            TypeSelectorView(@type) do |type_selector|
                @type_selector = type_selector
            end

            HTML.div 'text' do
                HTML.textarea do |text_textarea|
                    value @text

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
                HTML.select do |type_select|
                    if not @type
                        HTML.option
                    end

                    @select = type_select
                end
            end
        end
    end
end