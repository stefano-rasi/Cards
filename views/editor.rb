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
        @textarea.value
    end

    def type
        @type_selector.type
    end

    def textarea
        @textarea
    end

    render do
        HTML.div 'editor' do
            TypeSelectorView(@type) do |type_selector|
                @type_selector = type_selector
            end

            HTML.div 'text' do
                HTML.textarea do |textarea|
                    value @text

                    @textarea = textarea

                    textarea.setAttribute('spellcheck', false)
                end
            end
        end
    end

    class TypeSelectorView < View
        def initialize(type)
            @type = type

            HTTP.get('/types') do |body|
                @types = JSON.load(body)

                render
            end
        end

        def type
            @select.value
        end

        render do
            HTML.div 'type' do
                HTML.select do |type_select|
                    if not @type
                        HTML.option
                    end

                    @types.sort.each do |type|
                        HTML.option text: type, value: type do
                            selected if type == @type
                        end
                    end

                    @select = type_select
                end
            end
        end
    end
end