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

FIELDS = ['type', 'text', 'printed', 'binder_id', 'attributes']

def card_html(card)
    attributes = card[:attributes].split.map { |attribute|
        key, value = attribute.split('=', 2)

        [key, value]
    }.to_h

    Card.classes.fetch(card[:type]).new(card[:text], attributes).to_html
rescue => error
    "<div class=\"card error\"><pre>#{Rack::Utils.escape_html("#{error.class}: #{error.message}")}</pre></div>"
end

def payload
    request.body.rewind

    JSON.parse(request.body.read).slice(*FIELDS).compact.transform_keys(&:to_sym)
end

get '/cards' do
    content_type 'application/json'

    conditions = {deleted: 0}

    if params[:printed]
        conditions[:printed] = params[:printed]

        order = Sequel.asc(:id)
    elsif params[:binder_id]
        conditions[:binder_id] = params[:binder_id]

        order = Sequel.desc(:id)
    else
        order = Sequel.desc(:id)
    end

    cards = DB[:cards].where(conditions).order(Sequel.asc(:printed), order).all

    cards.each do |card|
        card[:html] = card_html(card)
    end

    cards.to_json
end

get '/types' do
    content_type 'application/json'

    Card.classes.keys.to_json
end

get '/binders' do
    content_type 'application/json'

    DB[:binders].where(disabled: 0).order(:order).all.to_json
end

post '/cards' do
    content_type 'application/json'

    id = DB[:cards].insert(payload)

    {id: id}.to_json
end

patch '/cards/:id' do |id|
    card = DB[:cards].where(id: id).first

    fields = payload

    if [:type, :text, :attributes].any? { |key| fields.key?(key) && fields[key] != card[key] }
        DB[:cards_history].insert(
            type: card[:type],
            text: card[:text],
            card_id: card[:id],
            binder_id: card[:binder_id],
            attributes: card[:attributes]
        )
    end

    DB[:cards].where(id: id).update(fields)

    204
end

delete '/cards/:id' do |id|
    DB[:cards].where(id: id).update(deleted: 1)

    204
end
