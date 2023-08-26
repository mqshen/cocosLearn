require "cocos.init"

-- for CCLuaEngine traceback
main_error = {}


function __G__TRACKBACK__(msg)
    sdkMgr:sharedSkdMgr():post_lua_script_dump(tostring(msg), "LUA ERROR: " .. tostring(msg) .. "\n"..debug.traceback())
    if config.getPlatFormInfo() ~= kTargetWindows and configBeforeLoad.getDebugEnvironment() then
        -- tipsLayer.create("LUA ERROR: " .. tostring(msg), 10)
        local path = CCFileUtils:sharedFileUtils():getWritablePath()
        local file = assert(io.open(path.."/errorFile.txt","a+"))
        file:write("---------------"..os.date("%Y-%m-%d %X", os.time()).." ---------------------\n")
        file:write("LUA ERROR: " .. tostring(msg) .. "\n")
        file:write("------------------------------------\n")
        file:close()
    end

    table.insert(main_error, "LUA ERROR:"..tostring(msg))

    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")

    if config.getPlatFormInfo() ~= kTargetWindows and configBeforeLoad.getDebugEnvironment() then
        CCMessageBox(tostring(msg) .. "\n" .. debug.traceback(), "BUG")
    end
end

--基类
local _class={}
function class(super)
    local class_type={}
    class_type.ctor=false
    class_type.super=super
    class_type.new=function(...) 
            local obj={}
            setmetatable(obj,{ __index=_class[class_type] })
            do
                local create
                create = function(c,...)
                    if c.super then
                        create(c.super,...)
                    end
                    if c.ctor then
                        c.ctor(obj,...)
                    end
                end
 
                create(class_type,...)
            end
            
            return obj
        end
    local vtbl={}
    _class[class_type]=vtbl
    
    setmetatable(class_type,{__newindex=
        function(t,k,v)
            vtbl[k]=v
        end
    })
 
    if super then
        setmetatable(vtbl,{__index=
            function(t,k)
                local ret=_class[super][k]
                vtbl[k]=ret
                return ret
            end
        })
    end
 
    return class_type
end

local function  pairsTbCfg(tb_cfg)
    return function( _tb_cfg,k )
        local kk, vv = next(_tb_cfg,k)
        if kk then
            if vv._tb_cfg_new_value then
                return kk,vv._tb_cfg_new_value
            else
                return kk, tb_cfg._tb_convert_func_(kk,vv)
            end
            
        else
            return nil
        end
    end,tb_cfg._src_tb_,nil
end

if not _oldPairs then
    _oldPairs = pairs
    pairs = function(t)
        if t and t._src_tb_ then
            return pairsTbCfg(t)
        else
            return _oldPairs(t)
        end
    end
end

_tb_cfg_mt_ = {
    __index = function(table, key)
        local arr = table._src_tb_[key]
        if arr then
            if arr._tb_cfg_new_value then
                return arr._tb_cfg_new_value
            else
                return table._tb_convert_func_(key,arr)
            end
        else
            return nil
        end
    end,
    __newindex = function(table, key, value)
        table._src_tb_[key] = {_tb_cfg_new_value=value}
    end
}


-- require("game/main/userRead")

local function main()
    -- collectgarbage("setpause", 100)
    -- collectgarbage("setstepmul", 5000)
end

xpcall(main, __G__TRACKBACK__)

-- net
-- update
-- main
-- login
require("game/update/userDefault")
require("game/main/configBeforeLoad")
require("game/main/startAnimation")
require("game/update/LUpdate")
require("game/update/setConfigUI")
require("game/update/updateUI")
require("game/update/languageBeforeLogin")
require("game/login/sceneBeforeLogin")
require("game/main/endGameUI")
-- if configBeforeLoad.getPlatFormInfo() ~= kTargetWindows then
--     SDKLogin.registerSDK()
--     if sdkMgr:sharedSkdMgr():isSdkInit() then
--         StartAnimation.create()
--     end
-- else
--     StartAnimation.create()
-- end
StartAnimation.create()


-- require("game/main/userAgree")
-- userAgree.create("userAgreementText.lua")
-- ConvertLua.create_total("City_player_name.lua")
-- ConvertLua.create_total("City_NPC_name.lua")
-- ConvertLua.create_total("City_player_name_other.lua")
-- ConvertLua.create_total("not_war_panel.lua")


