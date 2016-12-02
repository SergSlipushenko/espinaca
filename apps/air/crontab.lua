return {
    -- Script 'dumb.lua' will run every cron cycle
    {every = 1, job = 'user'},
    {every = 6, job = 'sendTS', spawn=true},
    {every = 12, job ='rtc_sync', spawn=true}
}
