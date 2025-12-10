require 'slim'
require 'asciidoctor'

require_relative '../card'

class StudyCard < Card
    name 'study'

    def initialize(text, attributes)
        @html = Asciidoctor.convert(text)
    end
    
    def to_html
        template = Slim::Template.new('views/card/study.slim')

        template.render(self)
    end
end