require 'slim'

require_relative '../card'

class JapaneseWordCard < Card
    size 'B8'
    name 'jword'

    attribute('font', 'large')

    def initialize(text, attributes)
        super(text, attributes)

        parts = text.split(/\s*:\s*/)

        @english = parts[1]

        @japanese = JapaneseParser.new.parse(parts[0])
    end

    def html
        template = Slim::Template.new('views/cards/japanese.slim')

        template.render(self)
    end
end

class JapaneseParser < Parslet::Parser
    rule(:character) do
        str('\n').as(:en_space) |
        str('\m').as(:em_space) |
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