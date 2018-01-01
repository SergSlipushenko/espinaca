function dump(o, indent)
    local ind = indent or ''
    if type(o) == 'table' then
        if next(o) == nil then
            return '{}\n'
        end
        local s
        if indent then s = '\n' else s = '' end
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = ''..k..'' end
            s = s .. ind .. k .. ' = ' .. dump(v, ind .. '  ') 
            if type(v) ~= 'table' then s = s .. '\n' end
        end
        return  s
    else
        return tostring(o)
    end
end