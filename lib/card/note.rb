require 'slim'
require 'asciidoctor'

require_relative '../card'

class NoteCard
    include Card

    name 'note'

    def initialize(text, attributes)
        @html = Asciidoctor.convert(text)
    end
    
    def to_html
        template = Slim::Template.new('views/card/note.slim')

        template.render(self)
    end
end