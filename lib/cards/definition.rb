require 'slim'

require_relative '../card'

class DefinitionCard < Card
    size 'B8'
    name 'definition'

    def html
        template = Slim::Template.new('views/cards/definition.slim')

        template.render(self)
    end
end