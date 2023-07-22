require 'asciidoctor'

require_relative 'slim'

class TextCard < SlimCard
    def initialize(text, attributes)
        super(text, attributes)

        if self.class.slim
            @slim = self.class.slim
        else
            @slim = 'cards/text'
        end

        @html = Asciidoctor.convert(text)
    end
end