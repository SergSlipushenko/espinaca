return {
    sntp_server = '0.ua.pool.ntp.org',
    on_boot = {
        ntp_sync = false,
        net = {wifi=false, mqtt=false},
        script = 'user',
    },
    cron = {
        cron_cycle = 15*1000,
        dsleep = true,
        iter_cell = 21
    }
}
