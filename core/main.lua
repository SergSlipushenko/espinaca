print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
require 'utils'
nt = require 'netcon'
ftr.spawn(function()
    local _, bootr = node.bootreason()
    if (bootr ~= 5) or (bootr == 6 and rtctime and rtctime.get() == 0) then
        local cfg = ldfile('main_cfg.lua')
        local on_boot = (cfg or {}).on_boot or {}
        local iter_cell = ((cfg or {}).cron or {}).iter_cell
        cfg = nil 
        if rtcmem then rtcmem.write32(iter_cell,0) end
        local ft = ftr.Future()
        if on_boot.ntp_sync then
            nt_con.deploy(on_boot.net or {})
        end
        dofile('rtc_sync.lua')()
        local task_on_boot = ldfile(on_boot.script..'.lua')
        if task_on_boot then 
            nt.deploy(on_boot.net or {})
            print('Execute :', on_boot.script..'.lua')
            task_on_boot(); ftr.switch()
        else print('no boot task') end
        net_con = nil
    end
    local cron = ldfile('cron.lua'); if cron then cron() end
end)
