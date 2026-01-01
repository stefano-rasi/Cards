require 'json'

require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'

class SidebarView < View
    draw do
        HTML.div 'sidebar-view', ('expanded' if @expand) do
            HTML.div 'binders' do
                @binders.each do |binder|
                    binder_id = binder['id']
                    binder_name = binder['name']

                    HTML.div 'binder', ('selected' if binder_id == @binder_id) do
                        text binder_name

                        on(:click) { on_binder(binder_id, binder_name) }
                    end
                end
            end
        end
    end

    def initialize()
        @expand = nil

        @binders = []

        @binder_id = nil

        HTTP.get('/binders') do |body|
            @binders = JSON.parse(body)

            draw
        end
    end

    def expand=(expand)
        @expand = expand

        draw
    end

    def binder_id=(binder_id)
        @binder_id = binder_id

        draw
    end

    def on_binder(id, name, &block)
        if block_given?
            @on_binder_block = block
        else
            @on_binder_block.call(id, name)
        end
    end
end