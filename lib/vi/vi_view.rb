require 'lib/view/html'
require 'lib/view/view'
require 'lib/view/window'
require 'lib/view/document'

require_relative 'vi'

class ViView
    include View
    include ViEditor

    draw do
        HTML.div 'vi-view', "#{@mode}-mode", ('focus' if @focus) do |element|
            element.tabIndex = 0

            HTML.div 'lines' do
                y = 0

                @lines.each do |line|
                    HTML.div 'line' do
                        x = 0

                        if line.empty?
                            if @mode == :insert && x == @x && y == @y
                                HTML.input 'cursor' do |input|
                                    @input = input
                                end
                            else
                                HTML.div 'character empty', ('cursor' if x == @x && y == @y) do |element|
                                    element.innerHTML = '&nbsp;'

                                    if x == @x && y == @y
                                        @cursor = element
                                    end
                                end

                                HTML.br
                            end
                        else
                            line.each do |character|
                                if @mode == :insert && x == @x && y == @y
                                    HTML.input 'cursor' do |input|
                                        @input = input
                                    end
                                end

                                HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                    if character == ' '
                                        element.innerHTML = '&nbsp;'
                                    else
                                        element.textContent = character
                                    end

                                    if x == @x && y == @y
                                        @cursor = element
                                    end
                                end

                                x += 1
                            end

                            if @mode == :insert && y == @y && @x == x
                                HTML.input 'cursor' do |input|
                                    @input = input
                                end
                            end
                        end
                    end

                    y += 1
                end
            end

            HTML.div 'status-bar' do
                if @mode == :command
                    HTML.div 'command' do |element|
                        element.textContent = @command
                    end
                else
                    HTML.div 'mode' do |element|
                        element.textContent = "-- #{@mode.upcase} --"
                    end
                end

                if @pending || @multiplier
                    HTML.div 'pending' do |element|
                        element.textContent = "#{@pending}#{@multiplier}"
                    end
                end
            end
        end
    end

    def initialize(text, position=:start)
        super(text, position)

        Window.addEventListener('keydown', &method(:on_keydown))
        Window.addEventListener('compositionend', &method(:on_compositionend))
    end

    def focus()
        if @mode == :insert
            @input.focus()
        else
            @element.focus()
        end
    end

    def scroll()
        @cursor.scrollIntoView({block: :nearest})
    end

    def on_keydown(event)
        event = Native(event)

        if [@element, @input].include? Document.activeElement
            handled = key(event.key, event.ctrlKey, event.altKey)

            if handled != false
                event.preventDefault()
                event.stopPropagation()

                draw
                scroll
                focus
            end
        end
    end

    def on_compositionend(event)
        event = Native(event)

        event.data.split('').each do |key|
            key(key)
        end

        draw
        scroll
        focus
    end
end