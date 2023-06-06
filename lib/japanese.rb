require 'yaml'

require 'parslet'

require_relative 'slim'
require_relative 'text'

class KanjiCard < TextCard
    tag 'kanji'
    css 'kanji'
    size 'B8'
end

class JapaneseGrammarCard < TextCard
    css 'japanese-grammar'
    tags %w(japanese-grammar j-grammar)
    size 'B8'
end

class JapanesePhraseCard < SlimCard
    tags %w(japanese-phrase j-phrase)
    slim 'japanese'
    size 'B8'

    def initialize(node)
        @css = 'japanese-phrase'

        if node.has_attribute? 'font'
            @font = node.attribute('font')
        else
            @font = 'small'
        end

        text = node.text.strip

        @sections = JapaneseParser.new.parse(text)
    end
end

class JapaneseWordCard < SlimCard
    tags %w(japanese-word j-word)
    slim 'japanese'
    size 'B8'

    def initialize(node)
        @css = 'japanese-word'

        if node.has_attribute? 'font'
            @font = node.attribute('font')
        else
            @font = 'large'
        end

        text = node.text.strip

        @sections = JapaneseParser.new.parse(text)
    end
end

class JapaneseParser < Parslet::Parser
    rule(:character) do
        str('\*') |
        str('*').absent? >> any
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