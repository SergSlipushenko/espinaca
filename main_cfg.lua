return {
    sntp_server = '0.ua.pool.ntp.org',
    on_boot = {
        ntp_sync = false,
        net = {wifi = false, mqtt = false},
        script = 'dumb.lua',
    },
    cron = {
        cron_cycle = 10000,
        dsleep = true,
        iter_cell = 21
    }
}
