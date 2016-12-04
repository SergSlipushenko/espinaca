return {
    on_boot = {
        ntp_sync = false,
        script = 'user',
    },
    cron = {
        cycle = 5*1000,
        dsleep = true,
        cycle_cell = 21
    },
    crontab = {
        {every = 1, job = 'blink', async=true},
        {every = 1, job = 'mqtt', async=true}
    }
}
