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
viewfile = function(fname) 
    file.open(fname, "r")
    local buf = ''
    repeat 
        local line=file.readline()
        if line then
            local rline,_ = string.gsub(line, "\n", "")
            if buf:len() > 0 then buf = buf..'\n'..rline
            else buf = rline end
            if buf:len() > 128 then
                print(buf)
                buf=''
            end
        end
    until line == nil
    print(buf)
    file.close()
end
listfiles = function()
    print('{')
    for k,v in pairs(file.list()) do 
        print('"name":"'..k..'", "size":'..v..', "md5": "'..crypto.toBase64(crypto.fhash("sha1",k)):sub(1,8)..'"') 
    end;
    print('}')
end
raise_panic = function()
    while true do uart.write(0, 'Bye!') end
end