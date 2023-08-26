local loginBulletinList = {}

local main_layer = nil



local rolling_cur_item_indx = 0
local cur_bulletin_indx = 0

local TOTAL_ROLLING_ITEM = 2

local roling_list = nil

local function getConvertChildByName(parent,childName)
	assert(childName, "why get a nil child")
    local child = parent:getChildByName(childName)
    if child then 
       tolua.cast(child, child:getDescription())
    else
        -- print("node named["..childName.."]not found")
        -- print(debug.traceback())
    end
    return child
end




function loginBulletinList.remove()
	if main_layer then 
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		rolling_cur_item_indx  = nil
		cur_bulletin_indx = nil
		roling_list = nil
	end
end

function loginBulletinList.filldata(data)
	if not main_layer then return end
end

local function resetBulletinInfo()
	if not main_layer then return end
	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then return end
	local main_panel = getConvertChildByName(temp_widget,"main_panel")
	local item = nil

	local bulletinList = roling_list

	if cur_bulletin_indx > #bulletinList then 
		cur_bulletin_indx = 1
	end

	

	local label_title = nil
	local bulletinData = nil
	local temp_panel = nil
	local _richText = nil
	local re = nil
	local lastDataIndx = cur_bulletin_indx - 1
	for i = rolling_cur_item_indx , TOTAL_ROLLING_ITEM do 
		item = getConvertChildByName(main_panel,"item_" .. i)
		temp_panel = tolua.cast(item:getChildByName("Panel_richtext"),"Layout")
		label_title = getConvertChildByName(item,"label_title")

		lastDataIndx = lastDataIndx + 1
		if lastDataIndx > #bulletinList then 
			lastDataIndx = 1
		end
		item:setTag(lastDataIndx)
		
		bulletinData = bulletinList[lastDataIndx]
		if bulletinData then
			temp_panel:removeAllChildrenWithCleanup(true)
			_richText = RichText:create()
			_richText:setAnchorPoint(cc.p(0,1))
			_richText:ignoreContentAdaptWithSize(false)
			_richText:setSize(CCSizeMake(temp_panel:getSize().width, temp_panel:getSize().height))
			_richText:setPosition(cc.p(0, temp_panel:getSize().height))
			_richText:setVerticalSpace(2)
			temp_panel:addChild(_richText)

			re = RichElementText:create(1, ccc3(219,173,100), 255, "【" .. languagePack["announcement"] .. "】" .. bulletinData.title ,config.getFontName(), 20)
			_richText:pushBackElement(re)
			-- label_title:setText("【" .. languagePack["announcement"] .. "】" .. bulletinData.title)
		end
	end

	for i = rolling_cur_item_indx - 1,1,-1 do 
		item = getConvertChildByName(main_panel,"item_" .. i)
		label_title = getConvertChildByName(item,"label_title")
		temp_panel = tolua.cast(item:getChildByName("Panel_richtext"),"Layout")

		lastDataIndx = lastDataIndx + 1
		if lastDataIndx > #bulletinList then 
			lastDataIndx = 1
		end
		item:setTag(lastDataIndx)
		
		bulletinData = bulletinList[lastDataIndx]
		if bulletinData then
			temp_panel:removeAllChildrenWithCleanup(true)
			_richText = RichText:create()
			_richText:setAnchorPoint(cc.p(0,1))
			_richText:ignoreContentAdaptWithSize(false)
			_richText:setSize(CCSizeMake(temp_panel:getSize().width, temp_panel:getSize().height))
			_richText:setPosition(cc.p(0, temp_panel:getSize().height))
			_richText:setVerticalSpace(2)
			temp_panel:addChild(_richText)

			re = RichElementText:create(1, ccc3(219,173,100), 255, "【" .. languagePack["announcement"] .. "】" .. bulletinData.title ,config.getFontName(), 20)
			_richText:pushBackElement(re)
			-- label_title:setText("【" .. languagePack["announcement"] .. "】" .. bulletinData.title)
		end
	end
end

local function rollBulletinItem()
	if not roling_list then return end
	if #roling_list < 2 then return end

	if not main_layer then return end
	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then return end
	local main_panel = getConvertChildByName(temp_widget,"main_panel")

	local item = nil
	local actionDelay = nil
	local actionMove = nil
	local actionFinally = nil
	for i = 1, TOTAL_ROLLING_ITEM do 
		item = getConvertChildByName(main_panel,"item_" .. i)
		item:stopAllActions()
		actionDelay = cc.DelayTime:create(2)
		actionMove = CCMoveTo:create(2,ccp(item:getPositionX() - item:getContentSize().width,item:getPositionY()))
		actionFinally = cc.CallFunc:create(function ( )
	        if i == TOTAL_ROLLING_ITEM then 
	        	rolling_cur_item_indx = rolling_cur_item_indx + 1
	        	if rolling_cur_item_indx > TOTAL_ROLLING_ITEM then 
	        		rolling_cur_item_indx = 1
	        	end
	        	
	        	local tmpItem = nil
	        	local posX = 6
	        	for j = rolling_cur_item_indx,TOTAL_ROLLING_ITEM do 
	        		tmpItem = getConvertChildByName(main_panel,"item_" .. j)
	        		tmpItem:setPositionX(posX)
	        		posX = posX + tmpItem:getContentSize().width + 10
	        	end
	        	for j = rolling_cur_item_indx - 1,1,-1 do 
	        		tmpItem = getConvertChildByName(main_panel,"item_" .. j)
	        		tmpItem:setPositionX(posX)
	        		posX = posX + tmpItem:getContentSize().width + 10
	        	end
	        	cur_bulletin_indx = cur_bulletin_indx + 1
	        	resetBulletinInfo()
	        	rollBulletinItem()
	        end
	    end)
	    item:runAction(animation.sequence({actionDelay,actionMove,actionFinally}))
	end
end

function loginBulletinList.activeRollingBulletin()
	resetBulletinInfo()
	rollBulletinItem()

	local total_list = loginData.getBulletinList()
	for i = 1,#total_list do 
		if total_list[i].popup == 1 then 
			local loginBulletin = require("game/login/login_bulletin")
			loginBulletin.show(total_list[i].id)
			break
		end
	end

end

function loginBulletinList.create()
	if main_layer then return end
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_bulletin_list.json")
	temp_widget:setTag(999)
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(1,1))
	local posX =configBeforeLoad.getWinSize().width - 5
	local posY = configBeforeLoad.getWinSize().height - 5

	temp_widget:setPosition(cc.p(posX, posY))

	main_layer = TouchGroup:create()
	main_layer:addWidget(temp_widget)
 	loginGUI.add_login_content(main_layer)




 	roling_list = loginData.getBulletinRollingList()

 	--版本号
 	
 	local label_version = getConvertChildByName(temp_widget,"label_version")
 	if CCUserDefault:sharedUserDefault():getStringForKey("net") == "外网" then
		label_version:setText("Ver " .. CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion"))
	else
		label_version:setText("Ver " .. CCUserDefault:sharedUserDefault():getStringForKey("update_intraversion"))
	end

	local main_panel = getConvertChildByName(temp_widget,"main_panel")
	main_panel:setClippingEnabled(true)

	local item = nil
	for i =1 ,TOTAL_ROLLING_ITEM do 
		item = getConvertChildByName(main_panel,"item_" .. i)
		item:setBackGroundColorType(LAYOUT_COLOR_NONE)
		item:setTouchEnabled(true)
		item:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				local loginBulletin = require("game/login/login_bulletin")
				-- local indx = cur_bulletin_indx + rolling_cur_item_indx -1
				-- if indx > #roling_list then 
				-- 	indx = indx % #roling_list
				-- end
				local item = getConvertChildByName(main_panel,"item_" .. i)
				local bulletinData = roling_list[item:getTag()]
				local bulletinId = nil
				if bulletinData then bulletinId = bulletinData.id end
				local loginServerList = require("game/login/login_server_list")
				if not loginServerList.getInstance() then
					loginBulletin.show(bulletinId)
				end
			end
		end)
	end
	rolling_cur_item_indx = 1
	cur_bulletin_indx = 1

	main_layer:setVisible(false)
 	local action1 = CCFadeIn:create(0.3)
	local action2 = cc.CallFunc:create(function ( )
			main_layer:setVisible(true)
		end)
	local spawn = animation.spawn({action1, action2})
	main_layer:runAction(spawn)


	loginBulletinList.activeRollingBulletin()
end

function loginBulletinList.show(data)
	loginBulletinList.create()
end

function loginBulletinList.reloadData( )
	if not main_layer then 
		loginBulletinList.create() 
	end

	roling_list = loginData.getBulletinRollingList()
	resetBulletinInfo()

	
	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then return end
	local main_panel = getConvertChildByName(temp_widget,"main_panel")
	local flagHasBulletin = #roling_list > 0
	main_panel:setVisible(flagHasBulletin)

	local item = nil
	for i =1 ,TOTAL_ROLLING_ITEM do 
		item = getConvertChildByName(main_panel,"item_" .. i)
		item:setBackGroundColorType(LAYOUT_COLOR_NONE)
		item:setTouchEnabled(flagHasBulletin)
		item:setVisible(flagHasBulletin)
	end
end



return loginBulletinList
