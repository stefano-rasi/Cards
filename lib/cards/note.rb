require_relative 'text'

class NoteCard < TextCard
    name 'note'
    size 'B8'
    slim 'cards/note'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)
    end
end