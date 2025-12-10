require 'opal'

require 'json'

require 'lib/View/http'
require 'lib/View/document'

require_relative 'cards'

HTTP.get('/cards') do |body|
    cards = JSON.parse(body)

    element = CardsView.new(cards).element

    Document.body.appendChild(element)
end