require_relative 'text'

class NoteCard < TextCard
    name 'note'
    slim 'note'
    size 'B8'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)
    end
end