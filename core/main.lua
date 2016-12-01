print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
require 'utils'
nt = require 'netcon'
local cycle_done = true
local do_cycle = function(cron, cfg)
    if not cycle_done then print 'Cycle skipped'; return end
    cycle_done = false  
    local iter=rtcmem.read32(cfg.iter_cell)
    rtcmem.write32(cfg.iter_cell,iter+1)
    print('Cycle : ', iter) 
    for _, job in ipairs(cron) do
        if iter % job.every == 0 then
            if file.exists(job.job..'.lua') then
                print('Executed: ', job.job..'.lua')
                dofile(job.job..'.lua')()
                ftr.switch()
            else print(job.job..'.lua not found') end
        end
    end
    cycle_done = true
    if cfg.dsleep then 
        print('cycle ran in '..(timeit())..' ms')
        node.dsleep((cfg.cron_cycle-timeit()%cfg.cron_cycle)*1000,4)
    end
end

ftr.spawn(function()
    local _, bootr = node.bootreason()
    local cfg = ldfile('main_cfg.lua') or {}
    local on_boot = cfg.on_boot or {}
    local croncfg = cfg.cron or {}
    cfg = nil
    if (bootr ~= 5) or (bootr == 6 and rtctime and rtctime.get() == 0) then
        if rtcmem then rtcmem.write32(croncfg.iter_cell,0) end
        iter_cell = nil
        if on_boot.ntp_sync then
            nt.deploy({wifi=true})
        end
        dofile('rtc_sync.lua')()
        if on_boot.script then
            local task_on_boot = ldfile((on_boot.script or '')..'.lua')
            if task_on_boot then 
                nt.deploy(on_boot.net)
                print('Execute :', on_boot.script..'.lua')
                task_on_boot(); ftr.switch()
            else print(on_boot.script .. '.lua not found') end
        else print('No boot script.') end
    end
    local crontab = ldfile('crontab.lua')
    if not crontab then print('no crontab.lua'); return end
    do_cycle(crontab, croncfg)
    if not croncfg.dsleep then
        cron_tmr = tmr.create()
        cron_tmr:alarm(croncfg.cron_cycle, tmr.ALARM_AUTO, function() ftr.spawn(do_cycle, crontab, croncfg) end)
    end        
end)
