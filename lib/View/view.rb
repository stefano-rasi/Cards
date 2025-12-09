require 'opal'

class View
    def self.render(&block)
        if block_given?
            @render_block = block
        else
            @render_block
        end
    end

    def render
        if @element
            element = instance_eval(&self.class.render)

            @element.replaceWith(element)

            @element = element
        else
            @element = instance_eval(&self.class.render)
        end
    end

    def element
        if not @element
            @element = instance_eval(&self.class.render)
        end

        @element
    end
end