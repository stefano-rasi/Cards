require 'opal'
require 'json'
require 'base64'
require 'sinatra'

require_relative 'cards'
require_relative 'binders'

DB = SQLite3::Database.new('cards.db')

DB.results_as_hash = true

get '/' do
    if params[:binder]
        binder_name = params[:binder]

        binder = DB.get_first_row('SELECT * FROM binders WHERE name = ?', [ binder_name ])

        @binder_id = binder['id']
    end

    if params[:is_printed]
        @is_printed = params[:is_printed].to_i
    end

    slim :app
end

get '/views/*' do
    content_type 'application/javascript'

    path = "views/#{params[:splat][0]}"

    builder = Opal::Builder.new()

    builder.append_paths('.')

    builder.build('lib/View/console', debug: true)

    builder.build(path, debug: true)

    javascript = builder.to_s

    source_map = builder.source_map

    "#{javascript}\n//# sourceMappingURL=data:application/json;base64,#{Base64.strict_encode64(JSON.dump(source_map.as_json))}"
end