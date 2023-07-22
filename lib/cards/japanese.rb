require_relative 'slim'
require_relative 'text'

class KanjiCard < TextCard
    name 'kanji'
    size 'B8'
end

class JapanesePhraseCard < SlimCard
    names %w(japanese-phrase jphrase)
    size 'B8'
    slim 'cards/japanese'

    attribute('font', 'small')

    def initialize(text, attributes)
        super(text, attributes)

        @sections = JapaneseParser.new.parse(text)
    end
end

class JapaneseWordCard < SlimCard
    names %w(japanese-word jword)
    size 'B8'
    slim 'cards/japanese'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)

        @sections = JapaneseParser.new.parse(text)
    end
end

class JapaneseParser < Parslet::Parser
    rule(:character) do
        str('\ ').as(:space) |
        (str('\*') | str('*').absent? >> any)
    end

    rule(:furigana_base) do
        (any >> str('(')).present? >> any |
        str('[').ignore >> (str(']').absent? >> any).repeat(1) >> str(']').ignore
    end

    rule(:furigana_text) do
        str('(').ignore >> (str(')').absent? >> any).repeat(1) >> str(')').ignore
    end

    rule(:furigana) do
        furigana_base.as(:base) >> furigana_text.as(:text)
    end

    rule(:group) do
        (furigana.as(:furigana) | character.as(:character)).repeat(1)
    end

    rule(:text) do
        group.repeat(1).as(:groups)
    end

    rule(:bold) do
        str('*') >> text >> str('*')
    end

    rule(:sections) do
        (text.as(:text) | bold.as(:bold)).repeat(1)
    end

    root(:sections)
end