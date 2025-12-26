require 'json'

require 'sequel'
require 'sinatra'

require_relative 'lib/card'

require_relative 'lib/card/note'
require_relative 'lib/card/study'
require_relative 'lib/card/recipe'
require_relative 'lib/card/italian'
require_relative 'lib/card/japanese'

DB = Sequel.connect('sqlite://cards.db')

get '/cards' do
    content_type 'application/json'

    conditions = { deleted: 0 }

    if params[:printed]
        conditions[:printed] = params[:printed]

        id_order = Sequel.asc(:id)
    end

    if params[:binder_id]
        conditions[:binder_id] = params[:binder_id]

        id_order = Sequel.desc(:id)
    end

    cards = DB[:cards].where(conditions).order(Sequel.asc(:printed), id_order).all

    cards.to_json
end

get '/cards/:id' do |id|
    content_type 'application/json'

    card = DB[:cards].where(id: id).first

    card.to_json
end

get '/cards/:id/html' do |id|
    card = DB[:cards].where(id: id).first

    type = card[:type]
    text = card[:text]

    attributes = card[:attributes].split(/\s+/).map { |attribute|
        key, value = attribute.split('=')

        [ key, value ]
    }.to_h

    Card.classes[type].new(text, attributes).to_html
end

get '/types' do
    content_type 'application/json'

    Card.classes.keys.to_json
end

get '/binders' do
    content_type 'application/json'

    binders = DB[:binders].order(:order).all

    binders.to_json
end

post '/cards' do
    content_type 'application/json'

    request.body.rewind

    payload = JSON.parse(request.body.read)

    type = payload['type']
    text = payload['text']
    printed = payload['printed']
    binder_id = payload['binder_id']
    attributes = payload['attributes']

    fields = {
        type: type,
        text: text,
        binder_id: binder_id,
        attributes: attributes
    }

    fields[:printed] = printed if printed

    id = DB[:cards].insert(fields)

    { id: id }.to_json
end

patch '/cards/:id' do |id|
    request.body.rewind

    payload = JSON.parse(request.body.read)

    type = payload['type']
    text = payload['text']
    printed = payload['printed']
    binder_id = payload['binder_id']
    attributes = payload['attributes']

    fields = {}

    fields[:type] = type if type
    fields[:text] = text if text
    fields[:printed] = printed if printed
    fields[:binder_id] = binder_id if binder_id
    fields[:attributes] = attributes if attributes

    DB[:cards].where(id: id).update(fields)
end

delete '/cards/:id' do |id|
    DB[:cards].where(id: id).update(deleted: 1)
end