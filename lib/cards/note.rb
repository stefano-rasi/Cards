require_relative 'text'

class NoteCard < TextCard
    name 'note'
    size 'B8'
    slim 'cards/note'

    attribute('font', 'large')
end