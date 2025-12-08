class Card
    @@classes = {}

    def self.name(name)
        @@classes[name] = self
    end

    def self.classes
        @@classes
    end
end