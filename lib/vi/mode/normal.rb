module ViEditor
    def normal_mode(key, ctrl_key, alt_key)
        if ctrl_key || alt_key
            false
        else
            handled = true

            if @multiplier
                multiplier = @multiplier
            else
                multiplier = 1
            end

            case key
            when ':'
                @command = ':'

                @mode = :command
            when '$'
                x = @lines[@y].length-1

                if @pending == 'd'
                    history

                    (x - @x + 1).times do
                        @lines[@y].delete_at(@x)
                    end

                    @x = [@x - 1, 0].max
                else
                    @x = x
                end
            when '0'
                if @multiplier
                    new_multiplier = (@multiplier.to_s + key).to_i
                else
                    @x = 0
                end
            when '1'..'9'
                if @multiplier
                    new_multiplier = (@multiplier.to_s + key).to_i
                else
                    new_multiplier = key.to_i
                end

                pending = @pending
            when 'a'
                history

                @x += 1 unless @lines[@y].empty?

                @mode = :insert
            when 'd'
                if @pending == 'd'
                    history

                    @lines.delete_at(@y)

                    @x = 0
                    @y = [[@y, @lines.length-1].min, 0].max

                    @lines = [[]] if @lines.empty?
                else
                    pending = 'd'
                end
            when 'j'
                y = [@y + multiplier, @lines.length-1].min

                if @pending == 'd'
                    history

                    (y - @y + 1).times do
                        @lines.delete_at(@y)
                    end

                    @x = 0
                    @y = [[@y, @lines.length-1].min, 0].max

                    @lines = [[]] if @lines.empty?
                else
                    @x = [[@x, @lines[y].length-1].min, 0].max
                    @y = y
                end
            when 'k'
                y = [@y - multiplier, 0].max

                if @pending == 'd'
                    history

                    (@y - y + 1).times do
                        @lines.delete_at(y)
                    end

                    @x = 0
                    @y = [y - 1, 0].max

                    @lines = [[]] if @lines.empty?
                else
                    @x = [[@x, @lines[y].length-1].min, 0].max
                    @y = y
                end
            when 'h'
                @x = [@x - multiplier, 0].max
            when 'l'
                @x = [@x + multiplier, @lines[@y].length-1].min
            when 'i'
                history

                @mode = :insert
            when 'p'
                if @yank
                    history

                    @lines.insert(@y, @yank)

                    @y += 1
                end
            when 'o'
                history

                @lines.insert(@y + 1, [] * multiplier)

                @x = 0
                @y += 1

                @mode = :insert
            when 'r'
                @mode = :replace
            when 's'
                history

                @lines[@y].delete_at(@x)

                @mode = :insert
            when 'u'
                if !@history.empty?
                    @lines = @history.pop

                    @y = [[@y, @lines.length-1].min, 0].max
                    @x = [[@x, @lines[@y].length-1].min, 0].max
                end
            when 'x'
                history

                @lines[@y].delete_at(@x)

                @x = [[@x, @lines[@y].length-1].min, 0].max
            when 'y'
                if @pending == 'y'
                    @yank = @lines[@y].clone
                else
                    pending = 'y'
                end
            when 'A'
                history

                @x = @lines[@y].length

                @mode = :insert
            when 'D'
                history

                x = @lines[@y].length-1

                (x - @x + 1).times do
                    @lines[@y].delete_at(@x)
                end

                @x = [@x - 1, 0].max
            when 'G'
                @x = 0
                @y = @lines.length-1
            when 'H'
                @x = 0
                @y = 0
            when 'I'
                @x = 0

                @mode = :insert
            when 'J'
                history

                @lines[@y] += @lines[@y + 1]

                @lines.delete_at(@y + 1)
            when 'O'
                history

                @lines.insert(@y, [] * multiplier)

                @x = 0

                @mode = :insert
            when :Escape
                pending = nil
            else
                if key.length > 1
                    handled = false

                    pending = @pending

                    new_multiplier = @multiplier
                end
            end

            @pending = pending

            @multiplier = new_multiplier

            handled
        end
    end
end