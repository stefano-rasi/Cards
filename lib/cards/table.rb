require 'yaml'

require_relative 'slim'

class RandomTableCard < SlimCard
    name %w(random-table r-table table)
    slim 'table'
    size 'B8'

    attribute('die', 'd6')
    attribute('columns', '1')

    def initialize(text, attributes)
        super(text, attributes)

        @columns = columns.to_i

        die = attribute('die')

        die_matches = die.match(/(\d*)d(\d+)/)

        if die_matches[1].empty?
            dice = 1
        else
            dice = die_matches[1].to_i
        end

        @faces = die_matches[2].to_i

        entries = YAML.load(text)

        possibilities = dice * @faces

        step, remainder = possibilities.divmod(entries.length)

        @entries = entries.map.with_index do |entry, i|
            start = die_notation(1 + i * step, faces, dices)
            finish = die_notation((i+1) * step, faces, dices)

            if start == finish
                die = start
            else
                die = "#{start}-#{finish}"
            end

            { text: entry, die: die }
        end

        if remainder != 0
            start = die_notation(possibilities - remainder + 1, faces, dices)
            finish = die_notation(possibilities, faces, dices)

            if start == finish
                die = start
            else
                die = "#{start}-#{finish}"
            end

            @entries << { text: 'Re-roll', die: die }
        end
    end

    def die_notation(number, faces, dice)
        if faces == 6
            quotient, modulus = number.divmod(faces)

            "#{quotient}#{modulus}"
        else
            number
        end
    end
end