require 'opal'
require 'native'

module HTTP
    def HTTP.get(resource, &block)
        $$.fetch(resource).then { |response|
            `response.text()`
        }.then { |body|
            block.call(body)
        }
    end

    def HTTP.put(resource, body, &block)
        options = {
            body: body,
            method: 'PUT'
        }

        $$.fetch(resource, options).then { |response|
            `response.text()`
        }.then { |body|
            block.call(body)
        }
    end

    def HTTP.post(resource, body, &block)
        options = {
            body: body,
            method: 'POST'
        }

        $$.fetch(resource, options).then { |response|
            `response.text()`
        }.then { |body|
            block.call(body)
        }
    end
end