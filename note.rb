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
        end
    end
end

class SimpleNoteCard < SlimCard
    tag 'simple-note'
    slim 'simple-note'
    size 'B8'

    def initialize(node)
        @text = node.text

        @title = node.attribute('title')
    end
end