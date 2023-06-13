require 'yaml'

require_relative 'slim'
require_relative 'text'

require_relative 'japanese/parser'

class KanjiCard < TextCard
    name 'kanji'
    size 'B8'
end

class JapaneseNoteCard < TextCard
    name %w(japanese-note j-note)
    size 'B8'
end

class JapanesePhraseCard < SlimCard
    name %w(japanese-phrase j-phrase)
    slim 'japanese'
    size 'B8'

    attribute('font', 'small')

    def initialize(text, attributes)
        super(text, attributes)

        @sections = JapaneseParser.new.parse(text)
    end
end

class JapaneseWordCard < SlimCard
    name %w(japanese-word j-word)
    slim 'japanese'
    size 'B8'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)

        @sections = JapaneseParser.new.parse(text)
    end
end