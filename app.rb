require 'sinatra'
require 'nokogiri'

require_relative 'card'

require_relative 'note'
require_relative 'latin'
require_relative 'music'
require_relative 'colors'
require_relative 'japanese'

get '/cards/*' do
    path = "cards/#{params[:splat][0]}"

    doc = Nokogiri::XML(File.read(path))

    @cards = doc.root.children.map { |child|
        tag = child.name

        klass = Card.find_class_with_tag(tag)

        if klass.nil?
            nil
        else
            klass.new(child)
        end
    }.compact

    slim :cards
end