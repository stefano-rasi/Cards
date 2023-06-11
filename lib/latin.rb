require_relative 'text'

class WordCard < TextCard
    tag 'word'
    css 'word'
    slim 'latin'
    size 'credit-card'

    def initialize(node)
        super(node)

        if node.has_attribute? 'font'
            @font = node.attribute('font')
        else
            @font = 'large'
        end
    end
end

class PhraseCard < TextCard
    tag 'phrase'
    css 'phrase'
    slim 'latin'
    size 'credit-card'

    def initialize(node)
        super(node)

        if node.has_attribute? 'font'
            @font = node.attribute('font')
        else
            @font = 'medium'
        end
    end
end