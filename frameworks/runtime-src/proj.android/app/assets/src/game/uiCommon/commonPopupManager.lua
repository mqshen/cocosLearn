local m_popup_layer = nil
local m_type = nil

local m_new_call_list = nil
local m_show_index = nil

local m_anim_index = nil

local m_lstCacheItemList = nil

local m_lstRemoveCallBackList = nil

local m_fFinallyCallback = nil

local m_bLockPlayEffect = nil

local function afterRmoveSelf(callbackList)
	if not callbackList then return end
	if #callbackList == 0 then return end

	local callback = table.remove(callbackList,1)
	if callback then callback() end

	afterRmoveSelf(callbackList)
end
local function remove_self()
	comItemReceiveEffect.remove()
	if m_popup_layer then

		m_type = nil
		m_new_call_list = nil
		m_show_index = nil

		m_popup_layer:removeFromParentAndCleanup(true)
		m_popup_layer = nil
		m_lstCacheItemList = nil

		if m_fFinallyCallback and type(m_fFinallyCallback) == "function" then 
			m_fFinallyCallback()
			m_fFinallyCallback = nil
		end
		-- uiManager.remove_self_panel(uiIndexDefine.POP_UP_UI)
	end

	m_bLockPlayEffect = nil
end


local function addCallBack(callback)
	if not m_lstRemoveCallBackList then 
		m_lstRemoveCallBackList = {}
	end
	table.insert(m_lstRemoveCallBackList,callback)
end





local function create()
	if m_popup_layer then return end
	local temp_widget = comItemReceiveEffect.create()
	if not temp_widget then return end
	local rootLayer = TouchGroup:create()
	rootLayer:addWidget(temp_widget)

	-- cc.Director:getInstance():getRunningScene():addChild(m_popup_layer,REWARD_EFFECT_SCENE)

	local function onTouch(eventType, x1, y1 )
		if eventType == "began" then 
			commonPopupManager.dealwithTouchEvent(x1,y1)
			return true
    	elseif eventType == "ended" then
    		return true
    	elseif eventType == "moved" then
    		return true
    	else
    		return true
    	end
	end

	local winSize = config.getWinSize()
	m_popup_layer = cc.LayerColor:create(cc.c4b(14, 17, 24,230),winSize.width, winSize.height)
	m_popup_layer:registerScriptTouchHandler(onTouch,false, 0, true)
	m_popup_layer:setTouchEnabled(true)
	m_popup_layer:addChild(rootLayer)
	cc.Director:getInstance():getRunningScene():addChild(m_popup_layer,REWARD_EFFECT_SCENE)
	m_popup_layer:ignoreAnchorPointForPosition(false)
	m_popup_layer:setAnchorPoint(cc.p(0.5,0.5))
	m_popup_layer:setPosition(cc.p(winSize.width/2, winSize.height/2))
	


	-- uiManager.add_panel_to_layer(m_popup_layer, uiIndexDefine.POP_UP_UI)
end

local function playGainEffect(itemInfo)
	if m_bLockPlayEffect then 
		if not m_lstCacheItemList then 
			m_lstCacheItemList = {}
		end
		if itemInfo then 
			table.insert(m_lstCacheItemList,itemInfo)
		end
		return 
	end

	if not itemInfo then 
		if not m_popup_layer and m_lstCacheItemList and #m_lstCacheItemList > 0 then 
			create()
		end
		comItemReceiveEffect.beginReceiveList(m_lstCacheItemList)
		m_lstCacheItemList = nil
	else
		if not m_lstCacheItemList then 
			m_lstCacheItemList = {}
		end
		
		
		if not m_popup_layer then 
			create()
			comItemReceiveEffect.beginReceiveList({itemInfo})
		else
			table.insert(m_lstCacheItemList,itemInfo)
		end
	end
end


local function dealwithTouchEvent(x,y)
	if not m_popup_layer then
		return false
	end

	if comItemReceiveEffect.dealwithTouchEvent(x,y) then 
		return true
	else
		if m_lstCacheItemList and #m_lstCacheItemList > 0 then 
			playGainEffect()
			return true
		else
			local temp_callBackList = m_lstRemoveCallBackList
			remove_self()
			afterRmoveSelf(temp_callBackList)
			return true
		end
	end
end

-- 针对获取卡牌抽卡方式的特殊接口
local function gainExtractCardMode()
	if newGuideManager.get_guide_state() then
		return
	end

	local m_new_call_list = cardCallData.get_extract_new_info()
	if #m_new_call_list == 0 then
		return
	end

	require("game/uiCommon/com_item_receive_effect")
	
	local itemInfo = nil
	local name_pic = nil
	
 	local function finally()
	    cardCallListManager.play_new_get_anim()
 	end
 	m_fFinallyCallback = finally
 	
	for k,v in ipairs(m_new_call_list) do
		itemInfo = {}
		itemInfo.itemType = taskAwardType.TYPE_CARD_EXTRACT_MODE
		local name_pic = Tb_cfg_card_extract[v].name_img .. ".png"

		itemInfo.strContentImgeUrl = name_pic
		itemInfo.strContentText = nil
		itemInfo.strTypeImageUrl = ResDefineUtil.pop_up_res[1]
		itemInfo.strTipsText = nil
		-- if k == #m_new_call_list then 
		-- 	itemInfo.callback = finally
		-- end
		playGainEffect(itemInfo)
	end
end





--TODOTK 细化具体显示的资源
--
local function gainAwardItem(itemType,itemNum,finally_cb)
	if newGuideManager.get_guide_state() then
		return
	end
	
	require("game/uiCommon/com_item_receive_effect")
	local itemInfo = nil
	local function finally ()
		if itemInfo then 
			playGainEffect(itemInfo)
		end

		if finally_cb then 
			m_fFinallyCallback = finally_cb
		end
	end
	if itemType == taskAwardType.TYPE_BUILD_QUEUE then
		itemInfo = {}
		-- 获取建筑队列 itemNum 占位第几个建筑队列
		itemInfo.itemType = taskAwardType.TYPE_BUILD_QUEUE
		itemInfo.strContentImgeUrl = nil
		itemInfo.strContentText = languagePack["gain"] .. languagePack["new"] .. languagePack["buildQueue"] 
		itemInfo.strTypeImageUrl = ResDefineUtil.pop_up_res[3]
		itemInfo.strTipsText = nil
		finally()
	elseif itemType == taskAwardType.TYPE_NEW_SKILL then 
		itemInfo = {}
		-- 获取 新战法 itemNum 是技能id
		local skillName = "未知技能"
		if Tb_cfg_skill[itemNum] then 
			skillName = Tb_cfg_skill[itemNum].name
		end
		itemInfo.itemType = taskAwardType.TYPE_NEW_SKILL
		itemInfo.strContentImgeUrl = nil
		itemInfo.strContentText = skillName
		itemInfo.strTypeImageUrl = ResDefineUtil.pop_up_res[4]
		itemInfo.strTipsText = nil
		finally()
	elseif itemType == taskAwardType.TYPE_GOLD then
		itemInfo = {}
		-- 获取元宝 itemNum 占位数量
		itemInfo.itemType = taskAwardType.TYPE_GOLD
		itemInfo.strContentImgeUrl = nil
		itemInfo.strContentText = languagePack["gain"] .. itemNum ..  languagePack["jin"] .. languagePack["award"]
		itemInfo.strTypeImageUrl = ResDefineUtil.pop_up_res[2]
		itemInfo.strTipsText = nil
		finally()
		
	elseif itemType == taskAwardType.TYPE_CARD_HERO then
		-- 获取武将卡特效 其他地方实现 
		-- itemNum 占位 武将卡ID
		require("game/ui_anim_effect/C_E_AssistAnim")
		m_bLockPlayEffect = true
		C_E_AssistAnim.play_get_card_anim({itemNum},function()
			m_bLockPlayEffect = false
			playGainEffect()
		end)
	else
		print("\n\n[waring!!!] unknow what to do [gainTaskAwardItem]",itemType,itemNum)
	end
	
end

commonPopupManager = {
	remove_self = remove_self,
	dealwithTouchEvent = dealwithTouchEvent,
	gainExtractCardMode = gainExtractCardMode,
	gainAwardItem = gainAwardItem,
}