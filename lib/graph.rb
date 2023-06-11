require_relative 'card'

class GraphCard < Card
    tag 'graph'
    size 'B8'

    def initialize(node)
        @dot = node.text
    end

    def to_s
        tempfile = Tempfile.new()

        tempfile.write(@dot)
        tempfile.rewind()
        tempfile.close()

        output = File.dirname(tempfile.path)

        @svg = %x(dot -T svg #{tempfile.path})

        template = Slim::Template.new('views/graph.slim')

        template.render(self)
    end
end