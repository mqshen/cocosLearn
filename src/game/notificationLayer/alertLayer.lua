--弹出窗口

module("alertLayer", package.seeall)


function remove_self( )
    comAlertConfirm.remove_self()
end



-- TODOTK  添加处理 errorTips 里的tips 选项
function create(text,arg,confirmCallback,tipsArgTabs)
    if type(text) == "string" then 
        comAlertConfirm.show(languagePack["queren"],text,arg,nil,nil,confirmCallback)
    elseif type(text) == "table" then
        -- 旧的逻辑数据一般都是从errortips 那个表读取的
        if text[1] == 1 then 
            tipsLayer.create(text,nil,arg)
        else
            local title = text[2]
            local content = text[3]
            local tips = text[4]
            if type(tips) == "string" then 
                tips = {tips}
            end
            comAlertConfirm.setBtnLayoutType(text[1])
            comAlertConfirm.show(title,content,arg,tips,tipsArgTabs,confirmCallback)
        end
    end
end



--------- 功能玩法介绍  先暂时复用下errortip配置
function showFunctionIntro(cfgKey,contentArgTab,tipsArgTabs,confirmCallBack,cancelCallBack,closeCallBack)
    local cfgInfo = errorTable[cfgKey]
    if not cfgInfo then return end

    local title = cfgInfo[2]
    local content = cfgInfo[3]
    local tips = cfgInfo[4]
    if type(tips) == "string" then 
        tips = {tips}
    end
    comAlertConfirm.setBtnLayoutType(cfgInfo[1])
    comAlertConfirm.show(title,content,contentArgTab,tips,tipsArgTabs,confirmCallBack,cancelCallBack,closeCallBack)
end

