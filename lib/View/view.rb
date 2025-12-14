require 'opal'

class View
    def self.render(&block)
        if block_given?
            @render_block = block
        else
            @render_block
        end
    end

    def self.destroy(&block)
        if block_given?
            @destroy_block = block
        else
            @destroy_block
        end
    end

    def element
        if !@element
            @element = instance_eval(&self.class.render)
        end

        @element
    end

    def render()
        if @element
            if self.class.destroy
                instance_eval(&self.class.destroy)
            end

            element = instance_eval(&self.class.render)

            @element.replaceWith(element)

            @element = element
        else
            @element = instance_eval(&self.class.render)
        end
    end

    def destroy()
        if self.class.destroy
            instance_eval(&self.class.destroy)
        end
    end
end