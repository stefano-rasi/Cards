module ViEditor
    def insert_mode(key, ctrl_key, alt_key)
        if ctrl_key || alt_key
            false
        else
            handled = true

            case key
            when :Enter
                @lines.insert(@y + 1, [])

                @x = 0
                @y += 1
            when :Escape
                @x = [[@x, @lines[@y].length-1].min, 0].max

                @mode = :normal
            when :Backspace
                @lines[@y].delete_at(@x - 1)

                @x = [@x - 1, 0].max
            else
                if key.length == 1
                    @lines[@y].insert(@x, key)

                    @x += 1
                else
                    handled = false
                end
            end

            handled
        end
    end
end