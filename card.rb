class Card
    def self.tag(tag)
        @tags = [ tag ]
    end

    def self.tags(tags=nil)
        if tags.nil?
            @tags
        else
            @tags = tags
        end
    end

    def self.size(size=nil)
        if size.nil?
            @size
        else
            @size = size
        end
    end

    def self.descendants
        ObjectSpace.each_object(Class).select { |klass|
            klass < self
        }
    end

    def self.find_class_with_tag(tag)
        if not defined? @descendants_tags
            @descendants_tags = descendants.map { |klass|
                if not klass.tags.nil?
                    klass.tags.map { |tag|
                        [ tag.to_s, klass ]
                    }
                end
            }.compact.flatten(1).to_h
        end

        @descendants_tags[tag]
    end

    def size
        if defined? @size
            @size
        else
            self.class.size
        end
    end
end