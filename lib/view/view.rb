require 'opal'

require_relative 'html'

module View
    module ClassMethods
        def draw(&block)
            if block_given?
                @draw_block = block
            else
                @draw_block
            end
        end
    end

    def self.included(base)
        base.extend(ClassMethods)
    end

    def element
        @element = instance_eval(&self.class.draw) if !@element

        @element
    end

    def draw()
        if @element
            element = instance_eval(&self.class.draw)

            @element.replaceWith(element)

            @element = element
        else
            @element = instance_eval(&self.class.draw)
        end
    end
end