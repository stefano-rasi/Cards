require 'parslet'

class CardsParser < Parslet::Parser
    INDENTATION = 2

    rule(:space) { str(' ').repeat(1) }

    rule(:new_line) { str("\n") }
    rule(:new_line?) { new_line.maybe }
    rule(:new_lines?) { new_line.repeat(0) }

    rule(:indentation) do
        str(' ').repeat(INDENTATION, INDENTATION)
    end

    rule(:name) do
        (space.absent? >> str(':').absent? >> any).repeat(1)
    end

    rule(:key) do
        (space.absent? >> str('=').absent? >> any).repeat(1)
    end

    rule(:value) do
        str('"').ignore >> (str('"').absent? >> any).repeat(1) >> str('"').ignore |
        (space.absent? >> str(':').absent? >> any).repeat(1)
    end

    rule(:attribute) do
        key.as(:key) >> str('=') >> value.as(:value)
    end

    rule(:tag) do
        space.absent? >> name.as(:name) >> (space >> attribute).repeat(0).as(:attributes) >> str(':')
    end

    rule(:line) do
        indentation.ignore >> (new_line.absent? >> any).repeat(1) >> new_line?
    end

    rule(:inline) do
        space.ignore >> (new_line.absent? >> any).repeat(1) >> new_line?.ignore
    end

    rule(:text) do
        (line | new_line).repeat(1)
    end

    rule(:card) do
        tag.as(:tag) >> inline.as(:text) |
        tag.as(:tag) >> new_line >> text.as(:text)
    end

    rule(:cards) do
        (card >> new_lines?).repeat(1)
    end

    root(:cards)
end