require 'yaml'

require_relative 'slim'

class ColorsCard < SlimCard
    tag 'colors'
    slim 'colors'
    size 'B8'

    def initialize(node)
        @colors = YAML.load(node.text)
    end
end