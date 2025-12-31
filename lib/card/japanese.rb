require 'yaml'

require 'slim'
require 'parslet'

require_relative '../card'

class JapaneseWordsCard < Card
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
        template = Slim::Template.new('views/card/japanese/words.slim')

        template.render(self)
    end
end

class JapanesePhrasesCard < Card
    name 'japanese/phrases'

    def initialize(text, attributes)
        @phrases = text.sub(/\s*-\s*/, '').split(/\n+\s*-\s*/).map { |phrase|
            phrase = phrase.sub(/^\s*jp:\s*/, '')

            japanese = ''

            while not /^\n+\s*en:/.match?(phrase)
                japanese += phrase[0]

                phrase = phrase[1..-1]
            end

            english = phrase.sub(/^\s*en:\s*/, '')

            {
                english: english,
                japanese: JapaneseParser.new.parse(japanese)
            }
        }
    end

    def to_html
        template = Slim::Template.new('views/card/japanese/phrases.slim')

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