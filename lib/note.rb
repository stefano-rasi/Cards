require_relative 'text'

class NoteCard < TextCard
    tag 'note'
    css 'note'
    slim 'note'
    size 'B8'

    def initialize(node)
        super(node)

        if node.has_attribute? 'size'
            @size = node.attribute('size')
        end

        if node.has_attribute? 'font'
            @font = node.attribute('font')
        else
            @font = 'large'
        end
    end
end