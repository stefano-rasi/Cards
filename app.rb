require 'sinatra'
require 'nokogiri'

require_relative 'lib/card'

require_relative 'lib/note'
require_relative 'lib/latin'
require_relative 'lib/music'
require_relative 'lib/colors'
require_relative 'lib/japanese'

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