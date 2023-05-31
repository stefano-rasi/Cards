require 'sinatra'
require 'nokogiri'

require_relative 'card'

require_relative 'note'
require_relative 'latin'
require_relative 'music'
require_relative 'japanese'

get '/cards/*' do
    path = "cards/#{params[:splat][0]}"

    doc = Nokogiri::XML(File.read(path)) { |config|
        config.noblanks
    }

    @cards = doc.root.children.map { |child|
        Card.find_class_with_tag(child.name).new(child)
    }

    slim :cards
end