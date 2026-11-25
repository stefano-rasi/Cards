require 'lib/view/html'
require 'lib/view/view'

require_relative 'icons'

class CardView
    include View

    PRINTED = ['not-printed', 'print-ready', 'printed']

    draw do
        content = @app.card_html(@card)

        HTML.div 'card-view', ('loading' if !content) do |element|
            HTML.div 'card-container' do
                html content if content

                on(:click) { @app.edit_card(@card) }
            end

            if !content
                if @app.state == :print
                    load_html
                else
                    observe(element)
                end
            end

            span(element)

            HTML.div 'button delete-button', title: 'delete' do
                html Icons[:trash]

                on(:click) { @app.delete_card(@card) }
            end

            printed = PRINTED[@card['printed']]

            HTML.div 'button print-button', printed, title: printed.tr('-', ' ') do
                HTML.span

                on(:click) { @app.print_card(@card) { draw } }
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
            end
        end
    end

    def initialize(app, card)
        @app = app
        @card = card
    end

    def load_html()
        @app.load_card_html(@card) { draw }
    end

    def span(element)
        %x{
            new ResizeObserver(function() {
                #{element.to_n}.style.gridRowEnd = 'span ' + Math.ceil(#{element.to_n}.offsetHeight + 20);
            }).observe(#{element.to_n})
        }
    end

    def observe(element)
        callback = proc { load_html }

        root = Document.querySelector('.cards-container').to_n

        %x{
            new IntersectionObserver(function(entries, observer) {
                if (entries.some(function(entry) { return entry.isIntersecting })) {
                    observer.disconnect();

                    #{callback}();
                }
            }, {root: #{root}, rootMargin: '100% 0px'}).observe(#{element.to_n})
        }
    end
end
