require 'js'

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
                    load_html_when_visible(element)
                end
            end

            fit_grid_rows(element)

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

    def fit_grid_rows(element)
        observer = JS.new($$[:ResizeObserver]) do
            element.style.gridRowEnd = "span #{(element.offsetHeight + 20).ceil}"
        end

        Native(observer).observe(element)
    end

    def load_html_when_visible(element)
        root = Document.querySelector('.cards-container')

        observer = JS.new($$[:IntersectionObserver], proc { |entries|
            if entries.any? { |entry| Native(entry).isIntersecting }
                Native(observer).disconnect

                load_html
            end
        }, {root: root, rootMargin: '100% 0px'}.to_n)

        Native(observer).observe(element)
    end
end
