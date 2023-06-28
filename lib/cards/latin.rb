require_relative '../text_card'

class WordCard < TextCard
    name 'word'
    size 'credit-card'
    slim 'cards/latin'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)
    end
end

class PhraseCard < TextCard
    name 'phrase'
    size 'credit-card'
    slim 'cards/latin'

    attribute('font', 'medium')

    def initialize(text, attributes)
        super(text, attributes)
    end
end