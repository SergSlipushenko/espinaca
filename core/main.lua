print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
require 'utils'
pheap()
ftr.spawn(function() 
    pheap()
    if rtctime == nil or rtctime.get() == 0 then
        local cfg = loadfile('main_cfg.lua')
        local on_boot = (cfg or {}).on_boot or {}
        local iter_cell = ((cfg or {}).cron or {}).iter_cell
        cfg = nil 
        local net_con = nil
        if rtcmem then rtcmem.write32(iter_cell,0) end
        local ft = ftr.Future()
        if on_boot.ntp_sync then
            net_con = loadfile('netcon.lua', net_con)
            ft:run(net_con.start, {wifi = true}, ft:callbk())
            if #net_on_boot == 0 then net_con.stop(); net_con = nil end
        end
        dofile('rtc_sync.lua')()
        local task_on_boot = loadfile(on_boot.script)
        if task_on_boot then 
            pheap()
            if #(on_boot.net or {}) ~= 0 then
                net_con = loadfile('netcon.lua', net_con)
                ft:run(net_con.start, on_boot.net or {}, ft:callbk())
            end
            pheap()
            task_on_boot(); ftr.switch()
        else print('no boot task') end
        net_con = nil
    end
    local cron = loadfile('cron.lua'); if cron then cron() end
end)
