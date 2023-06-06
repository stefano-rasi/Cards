require_relative 'text'

class WordCard < TextCard
    tag 'word'
    css 'word'
    size 'credit-card'
end

class PhraseCard < TextCard
    tag 'phrase'
    css 'phrase'
    size 'credit-card'
end