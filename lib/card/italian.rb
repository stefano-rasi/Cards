require 'yaml'

require 'slim'
require 'parslet'

require_relative '../card'

class ItalianWordsCard < Card
    name 'words'

    def initialize(text, attributes)
        @words = text.split(/\n+/).map { |word|
            word = word.sub(/^\s*-\s*/, '')

            color = word[/\{([^\}]+)\}/, 1]

            word = word.sub(/\{[^\}]+\}/, '')

            {word:, color:}
        }
    end

    def to_html
        template = Slim::Template.new('views/card/italian/words.slim')

        template.render(self)
    end
end

class ItalianPhrasesCard < Card
    name 'phrases'

    def initialize(text, attributes)
        @phrases = text.split(/\n+/).map { |phrase|
            phrase = phrase.sub(/^\s*-\s*/, '')

            ItalianParser.new.parse(phrase)
        }
    end

    def to_html
        template = Slim::Template.new('views/card/italian/phrases.slim')

        template.render(self)
    end
end

class ItalianParser < Parslet::Parser
    rule(:character) do
        str('{').absent? >>
        str('}').absent? >>
        any
    end

    rule(:text) do
        character.repeat(1)
    end

    rule(:color) do
        str('{') >> text.as(:text) >> str('}') >> str('(') >> any.as(:name) >> str(')')
    end

    rule(:sections) do
        (text.as(:text) | color.as(:color)).repeat(1)
    end

    root(:sections)
end