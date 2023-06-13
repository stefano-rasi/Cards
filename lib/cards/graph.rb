require_relative '../card'

class GraphCard < Card
    name 'graph'
    size 'B8'

    def initialize(text, attributes)
        @text = text
    end

    def to_s
        tempfile = Tempfile.new()

        tempfile.write(@text)
        tempfile.rewind()
        tempfile.close()

        output = File.dirname(tempfile.path)

        @svg = %x(dot -T svg #{tempfile.path})

        template = Slim::Template.new('views/graph.slim')

        template.render(self)
    end
end