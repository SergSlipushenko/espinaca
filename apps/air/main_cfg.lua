return {
    sntp_server = '0.ua.pool.ntp.org',
    on_boot = {
        ntp_sync = true,
        script = 'boot'
    },
    cron = {
        cron_cycle = 1000,
        dsleep = false,
        iter_cell = 21,
        cycles_to_skip = 5,
    },
    crontab = {
        {every = 5, job = 'sensors'},
        {every = 1, job = 'clock'},
        {every = 30, job = 'sendTS', spawn=true},
        {every = 3600, job ='rtc_sync', spawn=true}
    }    
}
