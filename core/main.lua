print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
require 'commons'
wifi.setmode(wifi.NULLMODE)
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
            node.restart()
        end)
    end
    n_cycle = rtcmem.read32(cfg.cycle_cell) 
    rtcmem.write32(cfg.cycle_cell,n_cycle + 1)
    print('Cycle : ', n_cycle)
    async_jobs = {} 
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

ftr.spawn(function()
    local cfg = ldfile('main_cfg.lua') or {}
    local on_boot = cfg.on_boot or {}
    local croncfg = cfg.cron or {}
    local crontab = cfg.crontab
    local count = 2
    -- try to boot in engineering mode
    gpio.mode(2, gpio.INPUT)
    for n = 5,1,-1 do
        if gpio.read(3) == gpio.LOW then count = count - 1; print(count) end
        ftr.sleep(150)
    end
    if count <= 0 then
        eng_mode = ldfile((cfg.eng_mode)..'.lua') or ldfile((cfg.eng_mode)..'.lc')
        if eng_mode then 
            print('Execute :', cfg.eng_mode)
            eng_mode(); return 
        end
    end
    -- Reset cycle counter on power on
    if rtcfifo then 
        if rtcfifo.ready() == 0 and croncfg.cycle_cell then
            rtcmem.write32(croncfg.cycle_cell, 0)
        end
        rtcfifo.prepare()
    end
    -- Execute on_boot script
    local _, bootr = node.bootreason()    
    if not((bootr == 5) or (bootr == 6 and rtctime and rtctime.get() ~= 0)) then
        if on_boot.ntp_sync then nt.deploy({wifi=true}) end
        if on_boot.ntp_sync or on_boot.ntp_sync == nil then
            dofile('rtc_sync.lua')()
        end
        if on_boot.script then
            local task_on_boot = ldfile((on_boot.script or '')..'.lua')
            if task_on_boot then 
                nt.deploy(on_boot.net)
                print('Execute :', on_boot.script..'.lua')
                task_on_boot(); ftr.switch()
            else print(on_boot.script .. '.lua not found') end
        else print('No boot script.') end
    end
    -- Start cron
    if not crontab then crontab = ldfile('crontab.lua') end
    if not crontab then print('no crontab'); return end
    do_cycle(crontab, croncfg)
    if not croncfg.dsleep then
        cron_tmr = tmr.create()
        cron_tmr:alarm(croncfg.cycle, tmr.ALARM_AUTO, function() ftr.spawn(do_cycle, crontab, croncfg) end)
    end
end)
