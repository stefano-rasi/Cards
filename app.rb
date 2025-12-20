require 'json'
require 'base64'

require 'opal'
require 'sequel'
require 'sinatra'

require_relative 'cards'

get '/' do
    if params.has_key?(:print)
        @print = true
    else
        @print = nil
    end

    if params[:binder_id]
        @binder_id = params[:binder_id]
    else
        @binder_id = nil
    end

    slim :app
end

get '/views/*' do
    content_type 'application/javascript'

    path = "views/#{params[:splat][0]}"

    builder = Opal::Builder.new()

    builder.append_paths('.')

    builder.build('lib/view/console')
    builder.build(path)

    "#{builder.to_s}\n//# sourceMappingURL=data:application/json;base64,#{Base64.strict_encode64(JSON.dump(builder.source_map.as_json))}"
end