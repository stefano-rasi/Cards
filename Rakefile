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
    output = 'public/app.js'

    file output => FileList['views/**/*.rb', 'lib/view/**/*.rb'] do
        require 'json'
        require 'opal'

        builder = Opal::Builder.new

        builder.append_paths('.')

        builder.build('lib/view/console')
        builder.build(source)

        File.write(output, "#{builder}\n//# sourceMappingURL=app.js.map")
        File.write("#{output}.map", JSON.dump(builder.source_map.as_json))

        puts "Compiled #{source} to #{output}"
    end

    task build: output

    task :watch do
        loop do
            begin
                Rake::Task[output].reenable
                Rake::Task[output].invoke
            rescue => error
                puts error.message
            end

            sleep 1
        end
    end
end

task :start, [:port] => ['style:build', 'opal:build'] do |task, arguments|
    port = arguments.fetch(:port, '4567')

    ruby 'app.rb', '-p', port
end

task default: ['style:build', 'opal:build']
