require 'json'

require 'sqlite3'
require 'sinatra'

require_relative 'lib/card'

require_relative 'lib/cards/note'
require_relative 'lib/cards/study'
require_relative 'lib/cards/recipe'
require_relative 'lib/cards/italian'
require_relative 'lib/cards/japanese'

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

get '/cards/:id/html' do |id|
    card = DB.get_first_row('SELECT * FROM cards WHERE id = ?', id)

    type = card['type']
    text = card['text']

    Card.classes[type].new(text, {}).to_html
end

put '/cards/:id' do |id|
    type = json_params['type']
    text = json_params['text']

    DB.execute('UPDATE cards SET type = ?, text = ? WHERE id = ?', id, type, text)
end

post '/cards' do
    content_type 'application/json'

    type = json_params['type']
    text = json_params['text']

    DB.execute('INSERT INTO cards (type, text) VALUES (?, ?)', type, text)

    id = DB.last_insert_row_id

    { id: id }.to_json
end

delete 'cards/:id' do
    DB.execute('DELETE FROM cards WHERE id = ?', id)
end