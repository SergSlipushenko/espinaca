print [[
 +-+-+-+-+-+-+-+-+
 |E|S|P|i|n|a|c|a|
 +-+-+-+-+-+-+-+-+]]
require 'commons'
local cfg = ldfile('main_cfg.lua') or {}
if next(cfg) == nil then
    local con_mode = ldfile('wsconsole.lua')
    if con_mode then
        print('Bootstraping with wsconsole.lua')
        con_mode()
        return
    end
end
local on_boot = cfg.on_boot or {}
cfg = nil
if not crontab then print('no crontab'); return end
local _, bootr = node.bootreason()
if not((bootr == 5) or (bootr == 6 and rtctime and rtctime.get() ~= 0)) then
    if on_boot.script then
        local task_on_boot = ldfile(on_boot.script..'.lua')
        if task_on_boot then
            print('Execute :', on_boot.script..'.lua')
            task_on_boot();
        else print(on_boot.script .. '.lua not found') end
    end
end

local crontab = (ldfile('main_cfg.lua') or {})
if crontab then
    (ldfile('cron.lua') or ldfile('cron.lc'))()
end