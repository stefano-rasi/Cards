require 'yaml'
require 'base64'

require_relative 'card'

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

class RhythmCard < MusicCard
    tag 'rhythm'
    erb 'rhythm'
    size 'credit card'

    def initialize(node)
        staves = YAML.load(node.text)

        if staves.respond_to? :each
            @staves = staves
        else
            @staves = [ staves ]
        end

        if node.has_attribute? 'time'
            @time = node.attribute('time')
        else
            @time = '4/4'
        end
    end
end

class ChordCard < MusicCard
    tag 'chord'
    erb 'chord'
    size 'B8'

    def initialize(node)
        @notes = node.text

        if node.has_attribute? 'clef'
            @clef = node.attribute('clef')
        else
            @clef = 'treble'
        end
    end
end

class PianoChordCard < MusicCard
    tag 'piano-chord'
    erb 'piano-chord'
    size 'B8'

    def initialize(node)
        staves = node.children.map { |child|
            clef = child.name
            notes = child.text

            { clef: clef, notes: notes }
        }

        @staves = { upper: staves[0], lower: staves[1] }
    end
end

class PianoCard < MusicCard
    tag 'piano'
    erb 'piano'
    size 'credit card'

    def initialize(node)
        if node.has_attribute? 'key'
            @key = node.attribute('key')
        else
            @key = 'c \major'
        end

        if node.has_attribute? 'time'
            @time = node.attribute('time')
        else
            @time = '4/4'
        end

        staves = node.children.map { |child|
            clef = child.name
            notes = child.text

            { clef: clef, notes: notes }
        }

        @staves = { upper: staves[0], lower: staves[1] }
    end
end