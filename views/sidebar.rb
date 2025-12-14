require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'

class SidebarView < View
    render do
        HTML.div 'sidebar-view' do
            if @expanded
                classList.add('expanded')
            end

            HTML.div 'first-row' do
                HTML.div 'button expand-button' do
                    HTML.span text: '☰'

                    on :click, &method(:on_expand)
                end

                HTML.div 'buttons' do
                    HTML.div 'button print-button' do
                        HTML.span text: 'P'

                        on :click, &method(:on_print)

                        classList.add('selected') if @print
                    end

                    HTML.div 'button home-button' do
                        HTML.span text: 'H'

                        on :click, &method(:on_home)

                        classList.add('selected') if @home
                    end
                end
            end

            HTML.div 'binders' do
                @binders.each do |binder|
                    HTML.div 'binder' do
                        binder_id = binder['id']
                        binder_name = binder['name']

                        if binder_id == @binder_id
                            classList.add('selected')
                        end

                        HTML.span 'icon', text: '▶'
                        HTML.span 'name', text: binder_name

                        on(:click) { on_change(binder_id, binder_name) }
                    end
                end
            end
        end
    end

    def initialize(binder_id)
        @home = false
        @print = false

        @binders = []

        @expanded = true

        @binder_id = binder_id

        HTTP.get('/binders') do |body|
            @binders = JSON.parse(body)

            render
        end
    end

    def binder_id
        @binder_id
    end

    def home=(home)
        @home = home
    end

    def print=(print)
        @print = print
    end

    def binder_id=(binder_id)
        @binder_id = binder_id
    end

    def on_home(&block)
        if block_given?
            @on_home_block = block
        else
            @on_home_block.call()
        end
    end

    def on_print(&block)
        if block_given?
            @on_print_block = block
        else
            @on_print_block.call()
        end
    end

    def on_change(binder_id, binder_name, &block)
        if block_given?
            @on_change_block = block
        else
            @home = false
            @print = false

            @binder_id = binder_id

            @on_change_block.call(binder_id, binder_name)

            render
        end
    end

    def on_expand()
        if @expanded
            @expanded = false

            render
        else
            @expanded = true

            HTTP.get('/binders') do |body|
                @binders = JSON.parse(body)

                render
            end
        end
    end
end