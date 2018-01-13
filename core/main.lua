print [[
 +-+-+-+-+-+-+-+-+
 |E|S|P|i|n|a|c|a|
 +-+-+-+-+-+-+-+-+]]
require 'commons'
local cfg = ldfile('main_cfg.lua') or {}
if next(cfg) == nil then
    local f = ldfile('wsconsole.lua') or f_stub; f()
    print('Bootstraping with wsconsole.lua')
end
local on_boot_script = cfg.on_boot_script
local crontab = cfg.crontab
cfg = nil
local _, bootr = node.bootreason()
if not((bootr == 5) or (bootr == 6 and rtctime and rtctime.get() ~= 0)) then
    if on_boot_script then
        local success, task_on_boot = pcall(ldfile, on_boot_script..'.lua')
        if success and task_on_boot then
            print('Execute :', on_boot_script..'.lua')
            success, _ = pcall(task_on_boot)
        end
        if not success then 
            local f = ldfile('wsconsole.lua') or f_stub; f()
            print('Fallback to wsconsole.lua')
        end
    end
end
if crontab then
    (ldfile('cron.lua') or ldfile('cron.lc'))()
end
