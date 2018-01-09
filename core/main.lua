print [[
 +-+-+-+-+-+-+-+-+
 |E|S|P|i|n|a|c|a|
 +-+-+-+-+-+-+-+-+]]
require 'commons'
local cfg = ldfile('main_cfg.lua') or {}
if next(cfg) == nil then
    local wsc =ldfile('wsconsole.lua') or function() end; wsc()
    print('Bootstraping with wsconsole.lua')
end
local on_boot_script = cfg.on_boot_script
local crontab = cfg.crontab
cfg = nil
if not crontab then print('no crontab'); return end
local _, bootr = node.bootreason()
if not((bootr == 5) or (bootr == 6 and rtctime and rtctime.get() ~= 0)) then
    if on_boot_script then
        local task_on_boot = ldfile(on_boot_script..'.lua')
        if task_on_boot then
            print('Execute :', on_boot_script..'.lua')
            task_on_boot();
        else 
            print(on_boot_script..'.lua not found') 
            local wsc =ldfile('wsconsole.lua') or function() end; wsc()
            print('Fallback to wsconsole.lua')
        end
    end
end

local crontab = (ldfile('main_cfg.lua') or {})
if crontab then
    (ldfile('cron.lua') or ldfile('cron.lc'))()
end
