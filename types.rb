require 'json'

require 'sinatra'

get '/types' do
    content_type 'application/json'

    Card.classes.keys.to_json
end