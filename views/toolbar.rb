require 'lib/view/html'
require 'lib/view/view'

require_relative 'icons'

class ToolbarView
    include View

    draw do
        HTML.div 'toolbar-view' do
            HTML.div 'left-buttons' do
                button 'sidebar-expand-button', :menu, 'Sidebar (e)', @app.sidebar_expand do
                    @app.toggle_sidebar
                end

                button 'home-button', :home, 'Home (h)', @app.state == :home do
                    @app.home
                end

                button 'print-button', :print, 'Print (p)', @app.state == :print do
                    @app.print
                end
            end

            HTML.div 'right-buttons' do
                button 'cards-expand-button', :expand, 'Expand cards (v)', @app.cards_expand? do
                    @app.toggle_cards_expand
                end

                button 'card-new-button', :plus, 'New card (n)' do
                    @app.new_card
                end
            end
        end
    end

    def initialize(app)
        @app = app
    end

    def button(name, icon, title, selected = false, &action)
        HTML.div 'button', name, ('selected' if selected), title: title do
            html Icons[icon]

            on(:click, &action)
        end
    end
end
