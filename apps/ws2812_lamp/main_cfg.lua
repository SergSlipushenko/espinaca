return {
    eng_mode = 'mqconsole',
    on_boot = {
        ntp_sync = false,
        script = 'boot'
    },
    cron = {
        cycle = 500,
        dsleep = false,
        cycle_cell = 21,
        watchdog_interval = 5000,
    },
    crontab = {
        {every = 1, job = 'color_upd'},
        {every = 20, job = 'random'},
    }    
}
