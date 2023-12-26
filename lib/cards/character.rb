require 'slim'

require_relative '../card'

class CharacterCard < Card
    size 'B8'
    name 'character'

    def initialize(text, attributes)
        super(text, attributes)

        @name = text
    end

    def html
        template = Slim::Template.new('views/cards/character.slim')

        template.render(self)
    end
end