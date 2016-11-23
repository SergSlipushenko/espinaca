return {
    main = {
        wifi = true,
        sntp = true,
        wait_for_net = true,
        mqtt = true,
        console = true   
    },
    warmup_time = 35000,
    verbose = true,
    send = true,
    cycle = 15000,
    sleep_cycle = 15000,
    sleep_on_done = false,
    mhz19_pin = 2,
    base_font = u8g.font_10x20,
    mid_font = u8g.font_7x15,
    small_font = u8g.font_6x10,
}
