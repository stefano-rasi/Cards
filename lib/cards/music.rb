require 'yaml'
require 'base64'

require 'nokogiri'

require_relative '../card'

class MusicCard < Card
    def to_s
        template = ERB.new(File.read("views/music/#{name}.erb"))

        tempfile = Tempfile.new()

        tempfile.write(template.result(binding))
        tempfile.rewind()
        tempfile.close()

        output = File.dirname(tempfile.path)

        system "lilypond --png -dpreview -dresolution=500 -o #{output} #{tempfile.path}"

        @image = File.open("#{tempfile.path}.preview.png", 'rb', &:read)

        template = Slim::Template.new('views/music.slim')

        template.render(self)
    end
end

class RhythmCard < MusicCard
    tag 'rhythm'
    erb 'rhythm'
    size 'credit-card'

    attribute('time', '4/4')

    def initialize(text, attributes)
        super(text, attributes)

        staves = YAML.load(text)

        if staves.respond_to? :each
            @staves = staves
        else
            @staves = [ staves ]
        end
    end
end

class ChordCard < MusicCard
    name 'chord'
    size 'B8'

    attribute('key', 'c \major')
    attribute('clef', 'treble')
    attribute('scale', 30)
    attribute('duration', 4)

    def initialize(text, attributes)
        super(text, attributes)

        @notes = text
    end
end

class PianoChordCard < MusicCard
    name 'piano-chord'
    size 'B8'

    attribute('key', 'c \major')
    attribute('scale', 30)
    attribute('duration', 4)

    def initialize(text, attributes)
        super(text, attributes)

        doc = Nokogiri::XML("<root>#{text}</root>")

        staves = doc.root.children.map { |child|
            clef = child.name
            notes = child.text

            { clef: clef, notes: notes }
        }

        @staves = { upper: staves[0], lower: staves[1] }
    end
end

class PianoCard < MusicCard
    name 'piano'
    size 'credit-card'

    attribute('key', 'c \major')
    attribute('time', '4/4')

    def initialize(text, attributes)
        super(text, attributes)

        doc = Nokogiri::XML("<root>#{text}</root>")

        staves = doc.root.children.map { |child|
            clef = child.name
            notes = child.text

            { clef: clef, notes: notes }
        }

        @staves = { upper: staves[0], lower: staves[1] }
    end
end