require 'json'

require 'sqlite3'
require 'sinatra'

require_relative 'lib/card'

require_relative 'lib/card/note'
require_relative 'lib/card/study'
require_relative 'lib/card/recipe'
require_relative 'lib/card/italian'
require_relative 'lib/card/japanese'

get '/cards' do
    content_type 'application/json'

    if params[:binder_id] && !params[:binder_id].empty?
        binder_id = params[:binder_id]

        cards = DB.execute('SELECT * FROM cards WHERE is_deleted = 0 AND binder_id = ? ORDER BY id DESC', [ binder_id ])
    elsif params[:is_printed] && !params[:is_printed].empty?
        is_printed = params[:is_printed]

        cards = DB.execute('SELECT * FROM cards WHERE is_printed = ? ORDER BY id ASC', [ is_printed ])
    else
        cards = DB.execute('SELECT * FROM cards WHERE is_deleted = 0 ORDER BY id DESC')
    end

    cards.to_json
end

get '/cards/:id' do |id|
    content_type 'application/json'

    card = DB.get_first_row('SELECT * FROM cards WHERE id = ?', id)

    card.to_json
end

get '/cards/:id/html' do |id|
    card = DB.get_first_row('SELECT * FROM cards WHERE id = ?', id)

    type = card['type']
    text = card['text']

    Card.classes[type].new(text, {}).to_html
end

get '/types' do
    content_type 'application/json'

    Card.classes.keys.to_json
end

get '/binders' do
    content_type 'application/json'

    binders = DB.execute('SELECT * FROM binders ORDER BY `order`')

    binders.to_json
end

put '/cards/:id' do |id|
    request.body.rewind

    payload = JSON.parse(request.body.read)

    type = payload['type']
    text = payload['text']

    is_printed = payload['is_printed']

    if payload['binder_id'].empty?
        binder_id = nil
    else
        binder_id = payload['binder_id']
    end

    if payload['attributes'].empty?
        attributes = nil
    else
        attributes = payload['attributes']
    end

    DB.execute('UPDATE cards SET type = ?, text = ?, attributes = ?, binder_id = ?, is_printed = ? WHERE id = ?', [ type, text, attributes, binder_id, is_printed, id ])
end

post '/cards' do
    content_type 'application/json'

    request.body.rewind

    payload = JSON.parse(request.body.read)

    type = payload['type']
    text = payload['text']

    if payload['binder_id'].empty?
        binder_id = nil
    else
        binder_id = payload['binder_id']
    end

    if payload['attributes'].empty?
        attributes = nil
    else
        attributes = payload['attributes']
    end

    DB.execute('INSERT INTO cards (type, text, attributes, binder_id) VALUES (?, ?, ?, ?)', [ type, text, attributes, binder_id ])

    id = DB.last_insert_row_id

    { id: id }.to_json
end

patch '/cards/:id' do |id|
    request.body.rewind

    payload = JSON.parse(request.body.read)

    if payload['binder_id']
        if payload['binder_id'].empty?
            binder_id = nil
        else
            binder_id = payload['binder_id']
        end

        DB.execute('UPDATE cards SET binder_id = ? WHERE id = ?', [ binder_id, id ])
    elsif payload['is_printed']
        is_printed = payload['is_printed']

        DB.execute('UPDATE cards SET is_printed = ? WHERE id = ?', [ is_printed, id ])
    end
end

delete '/cards/:id' do |id|
    DB.execute('UPDATE cards SET is_deleted = 1 WHERE id = ?', id)
end