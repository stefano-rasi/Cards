require 'asciidoctor'

require_relative 'slim_card'

class TextCard < SlimCard
    def initialize(text, attributes)
        super(text, attributes)

        if self.class.slim.nil?
            @slim = 'text_card'
        else
            @slim = self.class.slim
        end

        @html = Asciidoctor.convert(text)
    end
end