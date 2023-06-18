require 'slim'

require_relative '../card'

class SlimCard < Card
    def self.slim(slim=nil)
        if slim.nil?
            @slim
        else
            @slim = slim
        end
    end

    def slim
        if defined? @slim
            @slim
        else
            self.class.slim
        end
    end

    def to_s
        path = "views/#{slim}.slim"

        template = Slim::Template.new(path)

        template.render(self)
    end
end