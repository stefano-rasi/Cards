module Card
    extend self

    @classes = {}

    module ClassMethods
        def name(name)
            Card.classes[name] = self
        end
    end

    def classes
        @classes
    end

    def included(base)
        base.extend(ClassMethods)
    end
end