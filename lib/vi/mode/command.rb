module ViEditor
    def command_mode(key, ctrl_key, alt_key)
        if ctrl_key || alt_key
            false
        else
            handled = true

            case key
            when :Enter
                case @command
                when ':q'
                    on_quit()
                when ':w'
                    on_write()
                end

                @command = nil

                @mode = :normal
            when :Escape
                @command = nil

                @mode = :normal
            else
                if key.length == 1
                    @command += key
                else
                    handled = false
                end
            end

            handled
        end
    end
end