require 'lib/View/html'
require 'lib/View/http'
require 'lib/View/view'

class SidebarView < View
    render do
        HTML.div 'sidebar-view' do |sidebar|
            if @expanded
                sidebar.classList.add('expanded')
            end

            HTML.div 'first-row' do
                HTML.div 'button expand-button' do
                    HTML.span text: '☰'

                    on :click do
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

                HTML.div 'buttons' do
                    HTML.div 'button print-button' do
                        HTML.span text: 'P'

                        on :click do
                            @on_print_block.call()
                        end
                    end

                    HTML.div 'button home-button' do
                        HTML.span text: 'H'

                        on :click do
                            @on_home_block.call()
                        end
                    end
                end
            end

            HTML.div 'binders' do
                @binders.each do |binder|
                    HTML.div 'binder' do |binder_div|
                        binder_id = binder['id']
                        binder_name = binder['name']

                        if binder_id == @binder_id
                            binder_div.classList.add('selected')
                        end

                        HTML.span 'icon', text: '▶'
                        HTML.span 'name', text: binder_name

                        on :click do
                            @binder_id = binder_id

                            @on_change_block.call(@binder_id, binder_name)

                            render
                        end
                    end
                end
            end
        end
    end

    def initialize(binder_id)
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

    def binder_id=(binder_id)
        @binder_id = binder_id
    end

    def on_home(&block)
        @on_home_block = block
    end

    def on_print(&block)
        @on_print_block = block
    end

    def on_change(&block)
        @on_change_block = block
    end
end