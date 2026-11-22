require 'slim'
require 'parslet'

require_relative '../card'

class JapaneseWordsCard
    include Card

    name 'japanese/words'

    def initialize(text, attributes)
        @words = text.split(/\n+/).map { |line|
            parts = line.sub(/\s*-\s*/, '').split(/\s*:\s*/)

            color = parts[0][/\{([^\}]+)\}$/, 1]

            english = parts[1]

            japanese = parts[0].sub(/\{([^\}]+)\}$/, '')

            {
                color: color,
                english: english,
                japanese:JapaneseParser.new.parse(japanese)
            }
        }
    end

    def to_html
        template = Slim::Template.new('templates/card/japanese/words.slim')

        template.render(self)
    end
end

class JapanesePhrasesCard
    include Card

    name 'japanese/phrases'

    def initialize(text, attributes)
        @phrases = text.strip.split(/\n(?=\s*-)/).map { |phrase|
            match = phrase.match(/\A\s*-\s*jp:\s*(.*?)\n\s*en:\s*(.*)\z/m)

            raise "Missing jp: or en: in #{phrase.inspect}" if !match

            {
                english: match[2],
                japanese: JapaneseParser.new.parse(match[1])
            }
        }
    end

    def to_html
        template = Slim::Template.new('templates/card/japanese/phrases.slim')

        template.render(self)
    end
end

class JapaneseParser < Parslet::Parser
    rule(:character) do
        str('*').absent? >>
        str('{').absent? >>
        str('}').absent? >>
        any
    end

    rule(:furigana_base) do
        (str('}').absent? >> any >> str('(')).present? >> any |
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
        str('*') >> text.as(:text) >> str('*')
    end

    rule(:color) do
        str('{') >> text.as(:text) >> str('}') >> str('(') >> any.as(:name) >> str(')')
    end

    rule(:sections) do
        (text.as(:text) | bold.as(:bold) | color.as(:color)).repeat(1)
    end

    root(:sections)
end