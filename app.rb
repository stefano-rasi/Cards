require 'sinatra'

require_relative 'cards'

get '/' do
    if params.has_key?(:printed)
        @printed = params[:printed]
    end

    if params[:binder_id]
        @binder_id = params[:binder_id]
    end

    slim :app
end
