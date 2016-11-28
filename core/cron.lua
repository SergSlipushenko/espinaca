local cycle_done = true
local do_cycle = function(cron, cfg)
    if not cycle_done then print 'Cycle skipped'; return end
    cycle_done = false
    local iter=rtcmem.read32(cfg.iter_cell)
    rtcmem.write32(cfg.iter_cell,iter+1)
    print('Cycle : ', iter) 
    local services = {}
    for _, job in ipairs(cron) do
        if iter % job.every == 0 then
            print(string.format('Job: %s Services: %s %s', job.job, job.wifi and 'wifi,' or '', job.mqtt and 'mqtt' or '')) 
            if job.wifi then services.wifi = true end
            if job.mqtt then services.mqtt = true end
        end
    end
    if next(services) ~= nil then
        net_con = require 'netcon'
        net_con.start(services)
    end
    for _, job in ipairs(cron) do
        if iter % job.every == 0 then
            if file.exists(job.job..'.lua') then
                print('Executed: ', job.job..'.lua')
                dofile(job.job..'.lua')()
                ftr.switch()
            else print(job.job..'.lua not found') end
        end
    end
    if net_con then net_con.stop() end
    cycle_done = true
    if cfg.dsleep then 
        print('cycle ran in '..(timeit())..' ms')
        node.dsleep((cfg.cron_cycle-timeit()%cfg.cron_cycle)*1000,4)
    end
end
return function()
    local crontab
    crontab = ldfile('crontab.lua')
    if not crontab then print('no crontab.lua'); return end
    local cfg = (ldfile('main_cfg.lua') or {}).cron or {}
    do_cycle(crontab, cfg)
    if not cfg.dsleep then
        cron_tmr = tmr.create()
        cron_tmr:alarm(main_cfg.cron_cycle, tmr.ALARM_AUTO, function() ftr.spawn(do_cycle, crontab) end)
    end        
end
