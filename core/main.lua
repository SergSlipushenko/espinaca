print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
require 'utils'
ftr.spawn(function() 
    if rtctime == nil or rtctime.get() == 0 then
        local cfg = ldfile('main_cfg.lua')
        local on_boot = (cfg or {}).on_boot or {}
        local iter_cell = ((cfg or {}).cron or {}).iter_cell
        cfg = nil 
        local net_con = nil
        if rtcmem then rtcmem.write32(iter_cell,0) end
        local ft = ftr.Future()
        if on_boot.ntp_sync then
            net_con = ldfile('netcon.lua', net_con)
            net_con.start(on_boot.net or {})
            if not next(on_boot.net or {}) then net_con.stop(); net_con = nil end
        end
        dofile('rtc_sync.lua')()
        local task_on_boot = ldfile(on_boot.script..'.lua')
        if task_on_boot then 
            if next(on_boot.net or {}) then
                net_con = ldfile('netcon.lua', net_con)
                net_con.start(on_boot.net or {})
            end
            print('Execute :', on_boot.script..'.lua')
            task_on_boot(); ftr.switch()
        else print('no boot task') end
        net_con = nil
    end
    local cron = ldfile('cron.lua'); if cron then cron() end
end)
