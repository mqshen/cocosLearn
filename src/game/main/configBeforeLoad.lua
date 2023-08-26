-- configBeforeLoad.lua
module("configBeforeLoad", package.seeall)

local gWinSize = cc.Director:getInstance():getWinSize()

local gScaleX = gWinSize.width/1136
local gScaleY = gWinSize.height/640
local gSacle = (gScaleX>gScaleY and gScaleY) or gScaleX
local loginType = 0
local m_aid = nil
local gm_account = nil
local userAgreementVersion = nil

local m_iUpdateTime = nil
local m_iUseTime = nil

-- CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, function ( )
--     UpdateUI.resumeVideo()
-- end, "GAME_ENTER_FORWARD")

--设置全局缩放系数
function setgScale(value )
	gSacle = value
end

--获取全局缩放系数
function getgScale( )
	return gSacle
end

function getWinSize( )
	return gWinSize
end

function getPlatFormInfo( )
	return cc.Application:getInstance():getTargetPlatform()
end

function getFontName( )
	return "Arial"
end

-- 每次点击事件后锁住 
-- TODO 是否要只针对Button
-- local addTouchEventListenerOld = Widget.addTouchEventListener 
-- Widget.addTouchEventListener = function(self,callback)
--     local callbackOld = callback
--     callback = function(sender,evetType)
        
--         if evetType == TOUCH_EVENT_ENDED then 
--             sender:setTouchEnabled(false)
--             sender:runAction(
--                 cc.Sequence:createWithTwoActions(
--                     cc.DelayTime:create(0.1), 
--                     cc.CallFunc:create(function ( )        
--                         sender:setTouchEnabled(true)
--                     end)
--                 )
--             )
--         end
--         callbackOld(sender,evetType)
--     end
--     addTouchEventListenerOld(self,callback)
-- end


-------------------------------分支配置----------------------------------
-- 区分客户端开发版本
-- 本地开发环境不走更新流程
local b_isreleased = true

configBeforeLoad.VERSION_ALPHA = 0 -- 内测试版
configBeforeLoad.VERSION_BETA = 1 -- 测试版
configBeforeLoad.VERSION_STABLE = 2 -- 正式版

local i_clientVersion = configBeforeLoad.VERSION_ALPHA


function islocal()
    return not b_isreleased 
end

function isreleased()
    return b_isreleased
end

function getClientVersion()
    return i_clientVersion
end

-- 服务器类型
-- 0本机 1 内网 2 外网
-- SERVER_TYPE_LOCAL = 0
-- SERVER_TYPE_INNER = 1
-- SERVER_TYPE_OUTTER = 2
local SERVER_TYPE = 1

function setServerType(index )
    SERVER_TYPE = index
end

function getServerType()
    return SERVER_TYPE
end

---- 是否需要走获取服务器列表，公告列表等信息的流程
    -- 目前外网和本机不支持
function getIsNeedInfoFromService( )
    -- if SERVER_TYPE == 0 or SERVER_TYPE == 2 then 
    --     return false
    -- else
        return true
    -- end
end



--登陆服
-- local SERVER_IP = "192.168.11.144"
--游戏服
local GAME_SERVER_IP = "192.168.11.144"

--更新目录
--"http://218.107.63.49:9010/update_exterior/update_list.txt"
--更新文件夹
local UPDATE_DIR = "update_exterior"

--是否选择更新
local IF_UPDATE = true

--是否sdk登陆
local IF_SDKLOGIN = true

--sdk数据
local sdkData = nil

--是否首次登陆
local bFirstLogin = true

local login_server_userid = 0

function getDebugEnvironment( )
    local debug = CCUserDefault:sharedUserDefault():getStringForKey("DEBUG_MODE",true)
    if debug and string.len(debug) > 0 then
        if debug == "true" then
            DEBUG_MODE = true
        elseif debug == "false" then
            DEBUG_MODE = false
        end
    end
    
    return DEBUG_MODE
end

function setLoginServerUserid( id )
    login_server_userid = id
end

function getLoginServerUserid( )
    return login_server_userid
end

function setSdkData(uid, guest_uid, session, deviceId, platform, channel, app_channel, sdk_version, server_session, nt_uid )
    -- print(">>>>>>>>>>>>>>>>>>setSdkData1111")
    sdkData = {uid = uid, guest_uid = guest_uid, 
    session = session, deviceId = deviceId, 
    platform = platform, 
    channel= channel, 
    app_channel = app_channel,
    sdk_version = sdk_version,
    nt_uid = nt_uid,
    }
    if server_session then
        sdkData.server_session = server_session
    end
end

function getGuestUid( )
    local guset = ""
    if sdkData and sdkData.guest_uid and sdkData.guest_uid ~= "" then
        guset = sdkData.guest_uid.."@"..sdkData.platform.."."..sdkData.channel..".win.163.com"
    end
    return guset
end


function getSdkData( )
    return sdkData
end

function getIfSdkLogin( )
    return IF_SDKLOGIN
end

function setSdkLogin(flag )
    IF_SDKLOGIN = flag
end

function getIfUpdate( )
    return IF_UPDATE
end

function setIfUpdate( flag)
    IF_UPDATE = flag
end

-- 外服还没搭建service服务 所以暂时统一用一个
-- 登录服务地址
function getServiceIp()
    local address = CCUserDefault:sharedUserDefault():getStringForKey("SERVER_IP",true)
    if address and string.len(address) > 0 then
        SERVER_IP = address
    end
    return SERVER_IP 
end

-- 获取登陆服端口号
function getPort( )
    local address = CCUserDefault:sharedUserDefault():getStringForKey("LOGIN_PORT",true)
    if address and string.len(address) > 0 then
        LOGIN_PORT = tonumber(address)
    end
    return LOGIN_PORT 
end

-- 游戏服务器地址
function getGameServerIp()
    return GAME_SERVER_IP
end

function setServiceIp( str )
    SERVER_IP = str
end

function setGameServerIp( str )
    GAME_SERVER_IP = str
end

function setUpdateAddress(str)
    UPDATE_ADDR = str
end

-- 更新地址
function getUpdateAddress()
    local address = CCUserDefault:sharedUserDefault():getStringForKey("update_address",true)
    if address and string.len(address) > 0 then
        UPDATE_ADDR = address
    end
    return UPDATE_ADDR
end

function setUpdateDir(str)
    UPDATE_DIR = str
end

-- 更新目录
function getUpdateDir()
    return UPDATE_DIR
end

function getIsFirstLogin( )
    return bFirstLogin
end

function setIsFirstLogin(flag )
    bFirstLogin = flag
end

function setAid( str )
    m_aid = str
end

function getAid( )
    return m_aid
end

--富文本字符串解析
function richText_split(tempStr, arg )
    local pos = 1
    local repos = nil
    local s = nil
    local index = 1
    local tempArg = {}
    if not arg then
        tempArg["#"] = 1
        tempArg["@"] = 2
    else
        for i, v in ipairs(arg) do
            -- if v ~= "#" then
                tempArg[v] = i
            -- end
        end
    end

    local count = string.len(tempStr)
    local sub_str_tab = {}
    local str = ""
    -- while(true) do
    --  s = string.sub(tempStr,pos,pos )
    --  if tempArg[s] and pos <=count then
    --      if not repos then
    --          repos = pos+1
    --      else
    --          table.insert(sub_str_tab, {tempArg[s],string.sub(tempStr, repos, pos-1)})
    --          repos = nil
    --          if pos + 1 > count then
    --              break
    --          else
    --              tempStr = string.sub(tempStr, pos+1, count)
    --              pos = 0
    --          end
    --      end
    --  end
    --  pos = pos + 1
    --  if pos >count then
    --      break
    --  end
    -- end

    local isFirst = false
    while(true) do
        if pos > count then
            break
        end
        s = string.sub(tempStr,pos,pos )
        if not tempArg[s] then
            str = str..s
        end

        -- if pos <=count then
        if tempArg[s] and s ~= "#" then
            if not isFirst then
                table.insert(sub_str_tab, {1,str})
                isFirst = true
            else
                table.insert(sub_str_tab, {tempArg[s],str})
                isFirst = false
            end
            str = ""
   --   elseif s == "#" then
            -- table.insert(sub_str_tab, {1,str})
            -- str = ""
        else
            if pos == count then
                table.insert(sub_str_tab, {1,str})
            end
        end

        -- end
        pos = pos + 1
    end
    if #sub_str_tab == 0 then
        table.insert(sub_str_tab,{1, tempStr})
    end
    return sub_str_tab
end

--  字符串简单分割  如 "a,b,c" 分割成 {a,b,c}
function split_to_table(szFullString, szSeparator)
    local nFindStartIndex = 1  
    local nSplitIndex = 1  
    local nSplitArray = {}  
    while true do  
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
        if not nFindLastIndex then  
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
            break  
        end  
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
        nSplitIndex = nSplitIndex + 1  
    end
    return nSplitArray  
end

function exitGame( )
    sdkMgr:sharedSkdMgr():exitGame()
    cc.Director:getInstance():endToLua()
end

function isGmAccount( )
    return gm_account
end

function setGmAccount(flag )
    gm_account = flag
end

function setUserAgreementVers( str )
    userAgreementVersion = tostring(str)
end

function getUserAgreementVers(  )
    return userAgreementVersion or ""
end

function setUpdateTime( time )
    m_iUpdateTime = time
end

function setUpdateUseTime( time )
    m_iUseTime = time
end

function getUpdateTime( )
    return m_iUpdateTime
end

function getUpdateUseTime( )
    return m_iUseTime
end