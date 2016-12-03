return {
    on_boot = {
        ntp_sync = false,
        script = 'boot'
    },
    cron = {
        cycle = 1000,
        dsleep = false,
        cycle_cell = 21,
        cycles_to_skip = 5,
    },
    crontab = {
        {every = 1, job = 'clock'},
        {every = 5, job = 'sensors'},
        {every = 30, job = 'sendTS', async=true},
        {every = 3600, job ='rtc_sync', async=true}
    }    
}
