require 'parslet'

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

    rule(:bold_text) do
        str('*') >> text >> str('*')
    end

    rule(:sections) do
        (text.as(:text) | bold_text.as(:bold_text)).repeat(1)
    end

    root(:sections)
end