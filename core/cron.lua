ftr = require 'futures'
n_cycle = 0
local cycle_done = true
local do_cycle = function(cron, cfg)
    if not cycle_done then print('Cycle skipped.'); return end
    cycle_done = false
    local watchdog
    if cfg.watchdog_interval then
        watchdog = tmr.create()
        watchdog:alarm(cfg.watchdog_interval, tmr.ALARM_SINGLE, function()
            print('Cycle has hung. Reboot.')
            node.dsleep(1)
        end)
    end
    n_cycle = rtcmem.read32(cfg.cycle_cell)
    rtcmem.write32(cfg.cycle_cell,n_cycle + 1)
    print('Cycle : ', n_cycle)
    local async_jobs = {}
    for _, job in ipairs(cron) do
        if n_cycle % job.every == 0 then
            local jobfile = job.job..'.lua'
            if file.exists(jobfile) then
                print('Executed: ', jobfile)
                local jobrun = dofile(job.job..'.lua')
                if job.async then
                    async_jobs[job.job] = true
                    ftr.spawn(function()
                        jobrun()
                        async_jobs[job.job] = nil
                        print(job.job, ' done')
                    end)
                else
                    jobrun(); ftr.switch();
                    print(job.job, ' done')
                end
            else print(jobfile..'.lua not found') end
        end
    end
    while next(async_jobs) do ftr.sleep(100) end
    cycle_done = true
    if watchdog then watchdog:unregister() end
    if cfg.dsleep then
        print('cycle ran in '..(timeit())..' ms')
        node.dsleep((cfg.cycle-timeit()%cfg.cycle)*1000,2)
    end
end

return function()
    local cfg = ldfile('main_cfg.lua') or {}
    local croncfg = cfg.cron or {}
    local crontab = cfg.crontab
    cfg = nil
    -- Reset cycle counter on power on
    if rtcfifo then
        if rtcfifo.ready() == 0 and croncfg.cycle_cell then
            rtcmem.write32(croncfg.cycle_cell, 0)
            rtcfifo.prepare()
        end
    end
    ftr.spawn(do_cycle, crontab, croncfg)
    if not croncfg.dsleep then
        local cron_tmr = tmr.create()
        cron_tmr:alarm(croncfg.cycle, tmr.ALARM_AUTO, function() ftr.spawn(do_cycle, crontab, croncfg) end)
    end
end
