return {
    -- Script 'dumb.lua' will run every cron cycle
    {every = 1, job = 'blink'},
    {every = 2, job = 'mqtt'}
}
