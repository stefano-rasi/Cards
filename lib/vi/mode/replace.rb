module ViEditor
    def replace_mode(key, ctrl_key, alt_key)
        if ctrl_key || alt_key
            false
        else
            handled = true

            case key
            when :Escape
                @mode = :normal
            else
                if key.length == 1
                    @lines[@y][@x] = key

                    @mode = :normal
                else
                    handled = false
                end
            end

            handled
        end
    end
end