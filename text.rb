require 'asciidoctor'

require_relative 'slim'

class TextCard < SlimCard
    def self.css(css=nil)
        if css.nil?
            @css
        else
            @css = css
        end
    end

    def css
        if defined? @css
            @css
        else
            self.class.css
        end
    end

    def initialize(node)
        if self.class.slim.nil?
            @slim = 'text'
        else
            @slim = self.class.slim
        end

        text = node.text.sub(/^\n/, '')

        indentation = text.lines.first[/^( *)/, 1]

        asciidoc = text.gsub(/^ {#{indentation.length}}/, '')

        @html = Asciidoctor.convert(asciidoc)
    end
end