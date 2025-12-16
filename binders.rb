require 'json'

require 'sequel'
require 'sinatra'

get '/binders' do
    content_type 'application/json'

    binders = DB[:binders].order(:order).all

    binders.to_json
end