UIRoleForcesMain = {}

local uiUtil = require("game/utils/ui_util")
local StringUtil = require("game/utils/string_util")
local UIRoleForcesBase = require("game/roleForces/ui_role_forces_base")
local UIRoleForcesManor = require("game/roleForces/ui_role_forces_manor")
local UIRoleForcesRes = require("game/roleForces/ui_role_forces_res")

local main_layer = nil
local backPanel = nil
local main_view = nil

local uiIndex = uiIndexDefine.ROLE_FORCES_MAIN
local selectedIndx = nil
local user_id = nil
local user_name = nil
local function do_remove_self()
	-- 如果是其他人的势力
	require("game/roleForces/ui_role_forces_detail")
    UIRoleForcesDetail.remove_self()

	if main_layer then 

		UIRoleForcesBase.remove()
		UIRoleForcesManor.remove()
		UIRoleForcesRes.remove()
		if backPanel then 
			backPanel:remove()
			backPanel = nil
		end

		if main_view then 
			main_view:removeFromParentAndCleanup(true)
			main_view = nil 
		end
		selectedIndx = nil
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		user_id = nil
		user_name = nil
		uiManager.remove_self_panel(uiIndex)
		UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, UIRoleForcesMain.updateData)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, UIRoleForcesMain.updateData)
		UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.update, UIRoleForcesMain.updateData)
	end
end

function UIRoleForcesMain.remove_self()
    if not backPanel then return end
    uiManager.hideConfigEffect(uiIndex,main_layer,do_remove_self,999,{backPanel:getMainWidget()})
end


function UIRoleForcesMain.dealwithTouchEvent(x,y)
	return false
end

local function setViewIndx(indx)
	if indx >3 or indx < 1 then return end
	if selectedIndx == indx then return end
	local widget = main_layer:getWidgetByTag(999)
	local temp_btn = nil
	local is_btn_able = true
	for i = 1,3 do 
		temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
		is_btn_able = false
		if i ~= indx then is_btn_able = true end
		temp_btn:setTouchEnabled(is_btn_able)
		temp_btn:setBright(is_btn_able)
		uiUtil.setBtnLabel(temp_btn,not is_btn_able)
	end

	local main_panel = uiUtil.getConvertChildByName(widget,"main_panel")

	UIRoleForcesRes.remove()
	UIRoleForcesManor.remove()
	UIRoleForcesBase.remove()

	if indx == 1 then 
		UIRoleForcesBase.create(main_panel,user_id)
	elseif indx == 2 then 
		UIRoleForcesManor.create(main_panel)
	elseif indx == 3 then 
		UIRoleForcesRes.create(main_panel)
	end

	selectedIndx = indx 
end


local function dealwithClickTabBtn(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local indx = tonumber(string.sub(sender:getName(),5))
		setViewIndx(indx)
		UIRoleForcesMain.updateData()
	end
end

function UIRoleForcesMain.updateData()
	if selectedIndx == 1 then 
		UIRoleForcesBase.updateData()
	elseif selectedIndx == 2 then 
		UIRoleForcesManor.updateData()
	elseif selectedIndx == 3 then 
		UIRoleForcesRes.updateData()
	end
end


-- user_name_t 的作用会覆盖掉 user_id_t 的作用
function UIRoleForcesMain.create(user_id_t,user_name_t,indx)
	local is_own = false

	if not user_id_t and StringUtil.isEmptyStr(user_name_t) then 
		-- 两个都不传 默认打开自己的
		is_own = true
	else
		if user_id_t and userData.getUserId() == user_id_t then 
			is_own = true
		end

		if not StringUtil.isEmptyStr(user_name_t) then 
			-- 如果传名字进来
			-- user_name_t 的作用会覆盖掉 user_id_t 的作用
			if userData.getUserName() == user_name_t then 
				is_own = true
			end
		end
	end

	-- 如果是其他人的势力
	if not is_own then 
		require("game/roleForces/ui_role_forces_detail")
        UIRoleForcesDetail.create(user_id_t,user_name_t)
        return 
    end
	
    if main_layer then return end
    -- 跑到这里 那就只能是 玩家自己的势力界面
    
	user_id = userData.getUserId()
	user_name = userData.getUserName()
	
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/role_forces_main.json")
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	backPanel = UIBackPanel.new()
	local title_name = panelPropInfo[uiIndex][2]
	local temp_widget =  backPanel:create(widget, UIRoleForcesMain.remove_self,title_name)

	main_layer = TouchGroup:create()
	main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(main_layer, uiIndex)



	--按钮信息
	local temp_btn = nil
	for i = 1,3 do 
		temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
		temp_btn:setVisible(true)
		temp_btn:setTouchEnabled(true)
		temp_btn:addTouchEventListener(dealwithClickTabBtn)
	end
	if not is_own then 
		for i = 2,3 do 
			temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
			temp_btn:setVisible(false)
			temp_btn:setTouchEnabled(false)
		end
	end
	if not indx then 
		indx = 1
	end
	setViewIndx(indx)
	--TODOTK user_union_attr.name
	-- user_res
	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, UIRoleForcesMain.updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, UIRoleForcesMain.updateData)
	UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.update, UIRoleForcesMain.updateData)

	uiManager.showConfigEffect(uiIndex,main_layer,nil,999,{backPanel:getMainWidget()})
end

