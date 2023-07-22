require 'yaml'

require_relative 'slim'

class RandomTableCard < SlimCard
    names %w(random-table rtable)
    size 'B8'
    slim 'cards/random_table'

    attribute('columns', '1')

    def d6_notation(number)
        quotient, modulus = number.divmod(6)

        if quotient >= 6
            quotient = d6_notation(quotient)
        end

        "#{quotient}#{modulus + 1}"[-@die_count..-1]
    end

    alias d6 d6_notation

    def initialize(text, attributes)
        super(text, attributes)

        @columns = columns.to_i

        entries = YAML.load(text)

        @die_count = (entries.length.fdiv(6)).ceil

        face_count = 6 * @die_count

        step, remainder = face_count.divmod(entries.length)

        @entries = entries.map.with_index { |entry, i|
            range_begin = i * step
            range_end = (i + 1) * step - 1

            { text: entry, begin: range_begin, end: range_end }
        }

        if remainder != 0
            range_begin = face_count - remainder
            range_end = face_count - 1

            @entries << { text: 'Re-roll', begin: range_begin, end: range_end }
        end
    end
end