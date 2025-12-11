require 'opal'
require 'native'

require_relative 'view'
require_relative 'document'

module HTML
    def HTML.method_missing(name, *args, **kwargs, &block)
        element = Document.createElement(name)

        if not kwargs.empty?
            kwargs.each do |key, value|
                case key
                when 'text'
                    element.text = value
                when 'value'
                    element.value = value
                end
            end
        end

        if not args.empty?
            element.className = args[0]
        end

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
    alias_method :old_method_missing, :method_missing

    def method_missing(name, *args, &block)
        if HTML.element
            if /[A-Z]/.match(name)
                if self.class.const_defined?(name)
                    klass = self.class.const_get(name)

                    if klass < View
                        view_class = self.class.const_get(name)

                        view = view_class.new(*args, &block)

                        HTML.element.appendChild(view.element)

                        block.call(view)

                        view
                    end
                end
            else
                case name
                when 'on'
                    type = args[0]

                    HTML.element.addEventListener(type, &block)
                when 'data'
                    HTML.element.dataset[args[0]] = args[1]
                when 'value'
                    HTML.element.value = args[0]
                when 'selected'
                    HTML.element.selected = true
                end
            end
        else
            old_method_missing(name, *args, &block)
        end
    end
end