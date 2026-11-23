module Icons
    PATHS = {
        menu: 'M3 5h14M3 10h14M3 15h14',
        home: 'M3 9 10 3l7 6v8h-4.5v-5h-5v5H3z',
        print: 'M5.5 7.5V3h9v4.5M5.5 14H3V7.5h14V14h-2.5M5.5 11.5h9V17h-9z',
        expand: 'M10 2.5v15M6.5 6 10 2.5 13.5 6M6.5 14l3.5 3.5 3.5-3.5',
        plus: 'M10 4v12M4 10h12',
        close: 'M5 5l10 10M15 5 5 15',
        trash: 'M3.5 5.5h13M8 5.5v-2h4v2M5 5.5l.8 11h8.4l.8-11M8.5 8.5v5M11.5 8.5v5'
    }

    def self.[](name)
        "<svg viewBox=\"0 0 20 20\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.6\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"#{PATHS.fetch(name)}\"/></svg>"
    end
end
