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
        @type_selector.id
    end

    render do
        HTML.div :editor do
            TypeSelectorView.new(type) do |type_selector|
                @type_selector = type_selector
            end

            HTML.div :text do
                HTML.textarea :text do |textarea|
                    text @text

                    @textarea = textarea
                end
            end
        end
    end

    class TypeSelectorView < View
        def initialize(id)
            @id = id

            HTTP.get('/types') do |body|
                @types = JSON.load(body)

                render
            end
        end

        def id
            @select.value
        end

        render do
            HTML.div :type_selector do
                HTML.select :type do |type_select|
                    @types.each do |type|
                        id = type['id']
                        name = type['name']

                        HTML.option text: name, value: id do
                            selected if id == @id
                        end
                    end

                    @select = type_select
                end
            end
        end
    end
end