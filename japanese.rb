require 'yaml'

require_relative 'slim'
require_relative 'text'

class KanjiCard < TextCard
    tag 'kanji'
    css 'japanese kanji'
    size 'B8'
end

class JapanesePhraseCard < TextCard
    tag 'japanese-phrase'
    css 'japanese japanese-phrase'
    size 'B8'
end

class JapaneseWordCard < SlimCard
    tag 'japanese-word'
    slim 'japanese/word'
    size 'B8'

    def initialize(node)
        @characters = []

        if node.has_attribute? 'font'
            @font = node.attribute('font')
        end

        groups = YAML.load(node.content)

        if groups.respond_to? :each
            @groups = groups.map { |group|
                if group.respond_to? :key
                    furigana = group.values.first
                    characters = group.keys.first
                else
                    characters = group
                end

                { characters: characters, furigana: furigana }
            }
        else
            @groups = groups.split('').map { |character|
                { characters: character }
            }
        end
    end
end