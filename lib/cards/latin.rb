require_relative 'text'

class WordCard < TextCard
    name 'word'
    size 'B8'
    slim 'cards/latin'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)
    end
end

class PhraseCard < TextCard
    name 'phrase'
    size 'B8'
    slim 'cards/latin'

    attribute('font', 'medium')

    def initialize(text, attributes)
        super(text, attributes)
    end
end