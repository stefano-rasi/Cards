class Card
    class << self
        def name(name = nil)
            if name
                @name = name
            else
                @name
            end
        end

        def size(size=nil)
            if size
                @size = size
            else
                @size
            end
        end

        def attribute(key, value=nil)
            if value
                if not defined? @attributes
                    @attributes = {}
                end
    
                @attributes[key] = value
            else
                @attributes[key]
            end
        end

        def attributes
            @attributes
        end

        def descendants
            ObjectSpace.each_object(Class).select { |klass|
                klass < self
            }
        end

        def descendant(name)
            if not defined? @descendants
                @descendants = descendants.map { |klass|
                    [ klass.name, klass ]
                }.compact.to_h
            end

            @descendants[name]
        end
    end

    def initialize(text, attributes)
        @text = text
        @attributes = attributes
    end

    def text
        @text
    end

    def name
        self.class.name
    end

    def size
        if @attributes['size']
            @attributes['size']
        elsif defined? @size
            @size
        else
            self.class.size
        end
    end

    def attribute(key)
        if @attributes[key]
            @attributes[key]
        else
            self.class.attributes[key]
        end
    end

    def method_missing(m, *args, &block)
        attribute(m.to_s)
    end
end