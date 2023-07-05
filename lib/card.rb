class Card
    def self.name(name)
        @names = [ name ]
    end

    def self.names(names=nil)
        if names
            @names = names
        else
            @names
        end
    end

    def self.size(size=nil)
        if size
            @size = size
        else
            @size
        end
    end

    def self.attribute(key, value=nil)
        if value
            if not defined? @attributes
                @attributes = {}
            end

            @attributes[key] = value
        else
            @attributes[key]
        end
    end

    def self.attributes
        @attributes
    end

    def self.descendants
        ObjectSpace.each_object(Class).select { |klass|
            klass < self
        }
    end

    def self.descendant(name)
        if not defined? @descendants
            @descendants = descendants.map { |klass|
                if klass.names
                    klass.names.map { |name|
                        [ name.to_s, klass ]
                    }
                end
            }.compact.flatten(1).to_h
        end

        @descendants[name]
    end

    def initialize(text, attributes)
        @attributes = attributes
    end

    def names
        self.class.names
    end

    def size
        if @attributes.key? 'size'
            @attributes['size']
        elsif defined? @size
            @size
        else
            self.class.size
        end
    end

    def attribute(key)
        if @attributes.key? key
            @attributes[key]
        else
            self.class.attributes[key]
        end
    end

    def attribute?(key)
        (@attributes.key?(key) || self.class.attributes.key?(key))
    end

    def method_missing(m, *args, &block)
        attribute(m.to_s)
    end
end