require 'json'

require 'sqlite3'
require 'sinatra'

require_relative 'lib/card'

require_relative 'lib/card/note'
require_relative 'lib/card/study'
require_relative 'lib/card/recipe'
require_relative 'lib/card/italian'
require_relative 'lib/card/japanese'

DB = SQLite3::Database.new('cards.db')

DB.execute(%q{
    CREATE TABLE IF NOT EXISTS cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        text TEXT
    )
})

DB.results_as_hash = true

get '/cards' do
    content_type 'application/json'

    cards = DB.execute('SELECT * FROM cards')

    cards.to_json
end

get '/types' do
    content_type 'application/json'

    Card.classes.keys.to_json
end

get '/cards/:id/html' do |id|
    card = DB.get_first_row('SELECT * FROM cards WHERE id = ?', id)

    type = card['type']
    text = card['text']

    Card.classes[type].new(text, {}).to_html
end

put '/cards/:id' do |id|
    request.body.rewind

    payload = JSON.parse(request.body.read)

    type = payload['type']
    text = payload['text']

    DB.execute('UPDATE cards SET type = ?, text = ? WHERE id = ?', [ type, text, id ])
end

post '/cards' do
    content_type 'application/json'

    request.body.rewind

    payload = JSON.parse(request.body.read)

    type = payload['type']
    text = payload['text']

    DB.execute('INSERT INTO cards (type, text) VALUES (?, ?)', [ type, text ])

    id = DB.last_insert_row_id

    { id: id }.to_json
end

delete '/cards/:id' do |id|
    DB.execute('DELETE FROM cards WHERE id = ?', id)
end