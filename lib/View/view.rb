require 'opal'

require_relative 'html'

class View
    alias_method :old_method_missing, :method_missing

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

    def self.method_missing(name, *args, &block)
        if /[A-Z]/.match(name)
            if self.class.const_defined?(name)
                klass = self.class.const_get(name)

                if klass < View
                    view_class = self.class.const_get(name)

                    view = view_class.new(*args, &block)

                    if HTML.element
                        HTML.element.appendChild(view.element)
                    end

                    if block_given?
                        block.call(view)
                    end

                    view
                else
                    old_method_missing(name, *args, &block)
                end
            else
                old_method_missing(name, *args, &block)
            end
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