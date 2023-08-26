-- gameSpriteHotPoint.lua
-- 游戏精灵热点界面
module("GameSpriteHotPoint", package.seeall)
local isInit = false
local disPlayHotPointData = nil
local allHotPointData = nil
local indexHotPoint = nil
function remove( )
	disPlayHotPointData = nil
	allHotPointData = nil
	indexHotPoint = nil
	isInit = nil
end

function create(widget,changeBtn )
	if not isInit then
		disPlayHotPointData = {}
		allHotPointData = {}
		GameSpriteMgr.sendHotPoint("【system】热点问题")
		isInit = true
		local button = nil
		for i=1, 12 do
			table.insert(disPlayHotPointData, {button = tolua.cast(widget:getChildByName("Button_hot_"..i),"Button")})
			disPlayHotPointData[i].button:setTouchEnabled(true)
			disPlayHotPointData[i].button:addTouchEventListener(function ( sender, eventType)
				if eventType == TOUCH_EVENT_ENDED then
					GameSpriteMgr.sendQuestion(disPlayHotPointData[i].button:getTitleText())
					GameSpriteMainUI.changeTagButton(3)
	    			GameSpriteMgr.writeQuestion(disPlayHotPointData[i].button:getTitleText())
	        	end
			end)
			tolua.cast(disPlayHotPointData[i].button:getChildByName("ImageView_redian"),"ImageView"):setVisible(false)
		end

		changeBtn:setTouchEnabled(true)
		changeBtn:addTouchEventListener(function ( sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				changeHotPoint()
        	end
		end)
	end
end

local function hotPointStr(str, button )
	local flag = false
	local HotImage = nil
	local real_str = string.gsub(str, "@", function (n )
		if n == "@" then
			flag = true
			return ""
		end
	end)

	button:setTitleText(real_str)
	HotImage = tolua.cast(button:getChildByName("ImageView_redian"),"ImageView")
	if flag then
		HotImage:setVisible(true)
	else
		HotImage:setVisible(false)
	end
	-- return real_str, flag
end

function hotPointCallback(data )
	local hotPoint = data
	local count = 1
	for i, v in ipairs(hotPoint) do
		if string.len(v[2] )>0 then
			table.insert(allHotPointData,v[2])
			if count <= 12 then
				hotPointStr(v[2], disPlayHotPointData[count].button)
				indexHotPoint = count
				count = count + 1
			end
		end
	end
end

function changeHotPoint( )
	if not indexHotPoint then
		return
	end

	for i=1, 12 do
		if indexHotPoint >= #allHotPointData then
			indexHotPoint = 1
		else
			indexHotPoint = indexHotPoint + 1
		end
		hotPointStr(allHotPointData[indexHotPoint], disPlayHotPointData[i].button)
	end
end