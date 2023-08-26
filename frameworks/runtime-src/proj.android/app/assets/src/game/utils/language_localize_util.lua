local languageLocalizeUtil = {}


local function write()
    io.write('hello ', 'world')
end



--读取指定文件
local function getFile(file_name)
    local f = assert(io.open(file_name, 'r'))
    local string = f:read("*all")
    f:close()
    return string
end

local function getFileLine(file_name)
    local BUFSIZE = 84012
    local f = assert(io.open(file_name, 'r'))
    local lines,rest = f:read(BUFSIZE, "*line")
    f:close()
    return lines , rest
end

--字符串写入
local function writeFile(file_name,string)
    local f = assert(io.open(file_name, 'w'))
    f:write(string)
    f:close()
end


function languageLocalizeUtil.collectChinese()
    require("game/config/Language")
    local lines = ""
    for k,v in pairs(languagePack) do 
        lines = lines .. v .. "\n"
    end

    
    local fileName = CCFileUtils:sharedFileUtils():fullPathForFilename("game/utils/chinese.txt")
    writeFile(fileName, lines)
end


return languageLocalizeUtil