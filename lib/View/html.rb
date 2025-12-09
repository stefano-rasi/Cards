require 'opal'
require 'native'

require_relative 'view'
require_relative 'document'

module HTML
    def HTML.method_missing(name, *args, &block)
        element = Document.createElement(name)

        element.className = args[0]

        parent = @element

        if parent
            parent.appendChild(element)
        end

        @element = element

        block.call(element)

        @element = parent

        element
    end

    def HTML.element
        @element
    end
end

module Kernel
    def method_missing(name, *args, &block)
        if HTML.element
            case name
            when 'data'
                HTML.element.dataset[args[0]] = args[1]
            end
        end
    end
end