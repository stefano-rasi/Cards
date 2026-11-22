require 'lib/view/html'
require 'lib/view/view'

class ToolbarView
    include View

    draw do
        HTML.div 'toolbar-view' do
            HTML.div 'left-buttons' do
                button 'sidebar-expand-button', '☰', 'expand sidebar', @app.sidebar_expand do
                    @app.toggle_sidebar
                end

                button 'home-button', 'H', 'home', @app.state == :home do
                    @app.home
                end

                button 'print-button', 'P', 'print', @app.state == :print do
                    @app.print
                end
            end

            HTML.div 'right-buttons' do
                button 'cards-expand-button', 'V', 'expand cards', @app.cards_expand? do
                    @app.toggle_cards_expand
                end

                button 'card-new-button', '+', 'new card' do
                    @app.new_card
                end
            end
        end
    end

    def initialize(app)
        @app = app
    end

    def button(name, label, title, selected = false, &action)
        HTML.div 'button', name, ('selected' if selected), title: title do
            HTML.span text: label

            on(:click, &action)
        end
    end
end
