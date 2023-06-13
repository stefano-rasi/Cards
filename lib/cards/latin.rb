require_relative 'text'

class WordCard < TextCard
    name 'word'
    slim 'latin'
    size 'credit-card'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)
    end
end

class PhraseCard < TextCard
    name 'phrase'
    slim 'latin'
    size 'credit-card'

    attribute('font', 'medium')

    def initialize(text, attributes)
        super(text, attributes)
    end
end