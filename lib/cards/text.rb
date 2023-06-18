require 'asciidoctor'

require_relative 'slim'

class TextCard < SlimCard
    def initialize(text, attributes)
        super(text, attributes)

        if self.class.slim.nil?
            @slim = 'text'
        else
            @slim = self.class.slim
        end

        @html = Asciidoctor.convert(text)
    end
end