require 'json'
require 'base64'

require 'opal'
require 'sinatra'

require_relative 'cards'

get '/' do
    slim :root
end

get '/views/*' do
    content_type 'application/javascript'

    path = "views/#{params[:splat]}"

    builder = Opal::Builder.new()

    builder.append_paths('.')

    builder.build(path, debug: true)

    javascript = builder.to_s

    source_map = builder.source_map

    "#{javascript}\n//# sourceMappingURL=data:application/json;base64,#{Base64.strict_encode64(JSON.dump(source_map.as_json))}"
end