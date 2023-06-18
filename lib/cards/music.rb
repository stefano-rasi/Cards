require 'base64'
require 'parslet'

require_relative '../card'

class MusicCard < Card
    def self.erb(erb = nil)
        if erb.nil?
            @erb
        else
            @erb = erb
        end
    end

    def to_s
        template = ERB.new(File.read("views/music/#{self.class.erb}.erb"))

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

class ChordCard < MusicCard
    erb 'chord'
    name %w(chord music-note m-note)
    size 'B8'

    attribute('key', 'c \major')
    attribute('clef', 'treble')
    attribute('scale', '25')
    attribute('duration', '4')

    def initialize(text, attributes)
        super(text, attributes)

        music = MusicParser.new.parse(text)

        if music.key? :text
            clef = attribute('clef')

            notes = music[:text]

            @staves = { upper: { clef: clef, notes: notes } }
        else
            staves = music.map { |staff|
                clef = staff[:staff][:name]
                notes = staff[:staff][:text]

                { clef: clef, notes: notes }
            }

            @staves = { upper: staves[0], lower: staves[1] }
        end
    end
end

class MusicPhraseCard < MusicCard
    erb 'phrase'
    name %w(music-phrase m-phrase)
    size 'credit-card'

    attribute('key', 'c \major')
    attribute('time', '4/4')
    attribute('clef', 'treble')
    attribute('scale', '20')

    def initialize(text, attributes)
        super(text, attributes)

        music = MusicParser.new.parse(text)

        if music.key? :text
            clef = attribute('clef')

            notes = music[:text]

            @staves = { upper: { clef: clef, notes: notes } }
        else
            staves = music.map { |staff|
                clef = staff[:staff][:name]
                notes = staff[:staff][:text]

                { clef: clef, notes: notes }
            }

            @staves = { upper: staves[0], lower: staves[1] }
        end
    end
end

class MusicParser < Parslet::Parser
    INDENTATION = 2

    rule(:space) { str(' ').repeat(1) }

    rule(:new_line) { str("\n") }
    rule(:new_line?) { new_line.maybe }
    rule(:new_lines?) { new_line.repeat(0) }

    rule(:indentation) do
        str(' ').repeat(INDENTATION, INDENTATION)
    end

    rule(:name) do
        (space.absent? >> str(':').absent? >> any).repeat(1)
    end

    rule(:tag) do
        space.absent? >> name.as(:name) >> str(':')
    end

    rule(:line) do
        indentation.ignore >> (new_line.absent? >> any).repeat(1) >> new_line?
    end

    rule(:inline) do
        space.ignore >> (new_line.absent? >> any).repeat(1) >> new_line?.ignore
    end

    rule(:text) do
        (line | new_line).repeat(1)
    end

    rule(:unindented_line) do
        (new_line.absent? >> any).repeat(1) >> new_line?
    end

    rule(:unindented_text) do
        (unindented_line | new_line).repeat(1)
    end

    rule(:staff) do
        tag >> inline.as(:text) |
        tag >> new_line >> text.as(:text)
    end

    rule(:music) do
        (staff.as(:staff) >> new_lines?).repeat(1) |
        unindented_text.as(:text)
    end

    root(:music)
end