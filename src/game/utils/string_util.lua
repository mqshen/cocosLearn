local StringUtil = {}

--- 获取utf8编码字符串长度的
-- @param str
-- @return number
function StringUtil.utfstrlen(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end



-- 获取固定宽度的 固定fontSize 的字符串排版高度
function StringUtil.getstrHeightWithFontSize(str,dimensionWidth,fontsize,fontName,hAlignment)
    if not fontName then fontName = config.getFontName() end
    if not hAlignment then hAlignment = kCCTextAlignmentCenter end
	local dimensions = CCSizeMake(dimensionWidth,0)
	local tmp_ttf = CCLabelTTF:create(str,fontName,fontsize,dimensions,hAlignment)
	return tmp_ttf:getContentSize().height
end

-- 获取固定高度 固定fontSize 的字符串排版宽度
function StringUtil.getstrWidthWithFontSize(str,dimensionHeight,fontsize,fontName,hAlignment)
    if not fontName then fontName = config.getFontName() end
    if not hAlignment then hAlignment = kCCTextAlignmentCenter end
    local dimensions = CCSizeMake(0,dimensionHeight)
    local tmp_ttf = CCLabelTTF:create(str,fontName,fontsize,dimensions,hAlignment)
    return tmp_ttf:getContentSize().width
end

-- 去除字符串首位空格
function StringUtil.DelS(s)
    assert(type(s)=="string")
    s = " " .. s .. " "
    return s:match("^%s+(.-)%s+$")
end

function StringUtil.isEmptyStr(s)
    if not s then return true end
    if StringUtil.DelS(s) == "" then return true end
    return false 
end

function StringUtil.tableJoin2Str(tab,flag)
    assert(type(tab) == "table")
    assert(type(flag) == "string")
    local ret = ""
    local tabindx = 0
    for k,v in pairs(tab) do 
        ret = ret .. v .. flag
    end
    ret = string.sub(ret,0,string.len(ret) - string.len(flag)) -- hello word
    return ret 
end


function StringUtil.getLevelString(level)
    return "Lv." .. level
end



-- TODO 不应该放在这的

function StringUtil.XORBoolean(va,vb)
    if va ~= vb then return true end
    return false
end
return StringUtil
