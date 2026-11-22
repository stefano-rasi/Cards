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
        template = Slim::Template.new('templates/card/note.slim')

        template.render(self)
    end
end