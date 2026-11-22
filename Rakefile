namespace :style do
    source = 'styles/app.scss'
    output = 'public/app.css'

    file output => FileList['styles/**/*.scss'] do
        sh 'sass', '--embed-sources', source, output
    end

    task build: output

    task :watch do
        sh 'sass', '--watch', '--embed-sources', "#{source}:#{output}"
    end
end

task :start, [:port] => 'style:build' do |task, arguments|
    port = arguments.fetch(:port, '4567')

    ruby 'app.rb', '-p', port
end

task default: 'style:build'
