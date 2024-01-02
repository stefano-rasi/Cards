require 'slim'
require 'yaml'

require_relative '../card'

class CharacterCard < Card
    size 'B8'
    name 'character'

    def initialize(text, attributes)
        super(text, attributes)

        @name = attribute('name')
        @attributes = YAML.load(text)
    end

    def html
        template = Slim::Template.new('views/cards/character.slim')

        template.render(self)
    end
end