return {
    sntp_server = '0.ua.pool.ntp.org',
    on_boot = {
        ntp_sync = true,
        net = {wifi=true, mqtt=true},
        script = 'dumb',
    },
    cron = {
        cron_cycle = 10000,
        dsleep = true,
        iter_cell = 21
    }
}
