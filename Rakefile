namespace :style do
    source = 'styles'
    output = 'public/styles'

    task :build do
        sh 'sass', '--embed-sources', "#{source}:#{output}"
    end

    task :watch do
        sh 'sass', '--watch', '--embed-sources', "#{source}:#{output}"
    end
end

task :start, [:port] => 'style:build' do |task, arguments|
    port = arguments.fetch(:port, '4567')

    ruby 'app.rb', '-p', port
end

task default: 'style:build'
