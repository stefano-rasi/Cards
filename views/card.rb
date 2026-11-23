require 'lib/view/html'
require 'lib/view/view'

require_relative 'icons'

class CardView
    include View

    PRINTED = ['not-printed', 'print-ready', 'printed']

    draw do
        HTML.div 'card-view' do
            HTML.div 'card-container' do
                html @card['html']

                on(:click) { @app.edit_card(@card) }
            end

            HTML.div 'card-actions' do
                HTML.div 'binder' do
                    HTML.select do
                        @app.binders.each do |binder|
                            HTML.option text: binder['name'], value: binder['id'], selected: binder['id'] == @card['binder_id']
                        end
                    end

                    on(:change) { |event| @app.move_card(@card, Native(event).target.value.to_i) }
                end

                HTML.div 'button delete-button', title: 'delete' do
                    html Icons[:close]

                    on(:click) { @app.delete_card(@card) }
                end

                printed = PRINTED[@card['printed']]

                HTML.div 'button print-button', printed, title: printed.tr('-', ' ') do
                    HTML.span

                    on(:click) { @app.print_card(@card) }
                end
            end
        end
    end

    def initialize(app, card)
        @app = app
        @card = card
    end
end
