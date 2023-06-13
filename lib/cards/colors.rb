require 'yaml'

require_relative 'slim'

class ColorsCard < SlimCard
    name 'colors'
    slim 'colors'
    size 'B8'

    def initialize(text, attributes)
        colors = YAML.load(text)

        @colors = colors.map do |row|
            if row.respond_to? :key
                color = row.keys.first

                height = row.values.first

                if height.is_a? String
                    percentage = height.to_f

                    { color: color, percentage: percentage }
                else
                    proportion = height.to_f

                    { color: color, proportion: proportion }
                end
            else
                color = row

                proportion = 1.0

                { color: color, proportion: proportion }
            end
        end

        proportion_sum = @colors.reduce(0) { |sum, row|
            if row.key? :proportion
                sum + row[:proportion]
            else
                sum
            end
        }

        total_percentage = @colors.reduce(0) { |sum, row|
            if row.key? :percentage
                sum + row[:percentage]
            else
                sum
            end
        }

        remaining_percentage = 100.0 - total_percentage

        proportion_percentage = remaining_percentage / proportion_sum

        @colors.each do |row|
            if row.key? :proportion
                percentage = row[:proportion] * proportion_percentage

                row[:percentage] = percentage
            end
        end
    end
end