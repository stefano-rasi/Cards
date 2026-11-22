require 'rake'
require 'sinatra'

require_relative 'cards'

load 'Rakefile'

get '/' do
    if params.has_key?(:printed)
        @printed = params[:printed]
    end

    if params[:binder_id]
        @binder_id = params[:binder_id]
    end

    slim :app
end

get '/app.js' do
    task = Rake::Task['build/app.js']

    task.reenable
    task.invoke

    send_file 'build/app.js'
end
