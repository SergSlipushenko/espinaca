return {
    on_boot = {
    },
    cron = {
        cycle = 180*1000,
        dsleep = true,
        cycle_cell = 21
    },
    crontab = {
        {every = 1, job = 'measure'},
    }
}
