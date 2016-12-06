return {
    eng_mode = 'mqconsole',
    on_boot = {
        ntp_sync = false,
        script = 'boot'
    },
    cron = {
        cycle = 1000,
        dsleep = false,
        cycle_cell = 21,
        watchdog_interval = 5000,
    },
    crontab = {
        {every = 1, job = 'clock'},
        {every = 5, job = 'sensors'},
        {every = 30, job = 'sendTS', async=true},
        {every = 3600, job ='rtc_sync', async=true}
    }    
}
