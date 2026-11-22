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

namespace :opal do
    source = 'views/app.rb'
    output = 'build/app.js'

    file output => FileList['views/**/*.rb', 'lib/view/**/*.rb'] do
        require 'json'
        require 'opal'
        require 'base64'

        builder = Opal::Builder.new

        builder.append_paths('.')

        builder.build('lib/view/console')
        builder.build(source)

        source_map = Base64.strict_encode64(JSON.dump(builder.source_map.as_json))

        mkdir_p File.dirname(output), verbose: false

        File.write(output, "#{builder}\n//# sourceMappingURL=data:application/json;base64,#{source_map}")

        puts "Compiled #{source} to #{output}"
    end

    task build: output
end

task :start, [:port] => 'style:build' do |task, arguments|
    port = arguments.fetch(:port, '4567')

    ruby 'app.rb', '-p', port
end

task default: ['style:build', 'opal:build']
