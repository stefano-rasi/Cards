require 'slim'
require 'asciidoctor'

require_relative '../card'

class RecipeCard < Card
    name 'recipe'

    def initialize(text, attributes)
        @html = Asciidoctor.convert(text)
    end
    
    def to_html
        template = Slim::Template.new('views/card/recipe.slim')

        template.render(self)
    end
end