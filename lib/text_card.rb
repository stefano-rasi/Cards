require 'asciidoctor'

require_relative 'slim_card'

class TextCard < SlimCard
    def initialize(text, attributes)
        super(text, attributes)

        if self.class.slim
            @slim = self.class.slim
        else
            @slim = 'text_card'
        end

        @html = Asciidoctor.convert(text)
    end
end