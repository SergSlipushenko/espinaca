print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
require 'utils'
nt = require 'netcon'
local cycle_done = true
local cycles_to_skip = nil
local do_cycle = function(cron, cfg)
    if not cycle_done then 
        print('Cycle skipped. Left: ', cycles_to_skip);
        if cycles_to_skip then 
            if cycles_to_skip == 0 then node.restart() 
            else cycles_to_skip = cycles_to_skip - 1 end
        end
        return
    end
    cycle_done = false; cycles_to_skip=cfg.cycles_to_skip  
    local iter=rtcmem.read32(cfg.iter_cell)
    rtcmem.write32(cfg.iter_cell,iter+1)
    print('Cycle : ', iter) 
    for _, job in ipairs(cron) do
        if iter % job.every == 0 then
            local jobfile = job.job..'.lua'
            if file.exists(jobfile) then
                print('Executed: ', jobfile)
                local jobrun = dofile(job.job..'.lua')
                if job.spawn then ftr.spawn(jobrun)
                else jobrun(); ftr.switch() end
            else print(jobfile..'.lua not found') end
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
    local crontab = cfg.crontab
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
    if not crontab then crontab = ldfile('crontab.lua') end
    if not crontab then print('no crontab'); return end
    do_cycle(crontab, croncfg)
    if not croncfg.dsleep then
        cron_tmr = tmr.create()
        cron_tmr:alarm(croncfg.cron_cycle, tmr.ALARM_AUTO, function() ftr.spawn(do_cycle, crontab, croncfg) end)
    end
end)
