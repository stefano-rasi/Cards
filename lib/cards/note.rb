require 'slim'
require 'asciidoctor'

require_relative '../card'

class NoteCard < Card
    size 'B8'
    name 'note'

    attribute('font', 'medium')

    def initialize(text, attributes)
        super(text, attributes)

        @html = Asciidoctor.convert(text)
    end

    def html
        template = Slim::Template.new('views/cards/note.slim')

        template.render(self)
    end
end