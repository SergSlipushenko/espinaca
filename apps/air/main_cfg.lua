return {
    sntp_server = '0.ua.pool.ntp.org',
    on_boot = {
        ntp_sync = true,
        script = 'boot'
    },
    cron = {
        cron_cycle = 5000,
        dsleep = false,
        iter_cell = 21
    }
}
