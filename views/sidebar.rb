require 'lib/view/html'
require 'lib/view/view'

class SidebarView
    include View

    draw do
        HTML.div 'sidebar-view', ('expanded' if @app.sidebar_expand) do
            HTML.div 'binders' do
                @app.binders.each do |binder|
                    HTML.div 'binder', ('selected' if binder['id'] == @app.binder_id), text: binder['name'] do
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
