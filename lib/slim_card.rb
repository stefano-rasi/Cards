require 'slim'

require_relative 'card'

class SlimCard < Card
    def self.slim(slim=nil)
        if slim
            @slim = slim
        else
            @slim
        end
    end

    def slim
        if defined? @slim
            @slim
        else
            self.class.slim
        end
    end

    def html
        path = "views/#{slim}.slim"

        template = Slim::Template.new(path)

        template.render(self)
    end
end