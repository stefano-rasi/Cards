require 'lib/view/html'
require 'lib/view/view'

class SidebarView
    include View

    draw do
        HTML.div 'sidebar-view', ('expanded' if @app.sidebar_expand) do
            HTML.div 'binders' do
                group = nil

                @app.binders.each do |binder|
                    prefix, _, name = binder['name'].rpartition('/')

                    HTML.div 'group', text: prefix if !prefix.empty? && prefix != group

                    group = prefix

                    selected = binder['id'] == @app.binder_id

                    HTML.div 'binder', ('nested' if !prefix.empty?), ('selected' if selected), text: name, title: binder['name'] do
                        on(:click) { @app.binder(binder['id']) }
                    end
                end
            end
        end
    end

    def initialize(app)
        @app = app
    end
end
