require 'sinatra'

get '/binders' do
    content_type 'application/json'

    binders = DB.execute('SELECT * FROM binders ORDER BY `order`')

    binders.to_json
end

get '/sections' do |id|
    content_type 'application/json'

    binder_id = params['binder_id']

    sections = DB.execute('SELECT * FROM sections WHERE binder_id = ?', [ binder_id ])

    sections.to_json
end