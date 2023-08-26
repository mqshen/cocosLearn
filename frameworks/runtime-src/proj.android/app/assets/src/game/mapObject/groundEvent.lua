--地表事件
module("GroundEvent", package.seeall)
local m_arrEventData = nil

local function resetPosWhenMove( )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	for i,v in pairs(m_arrEventData) do
		label_start_x = math.floor(i/10000)
		label_start_y = i%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		ObjectManager.setObjectPos(v.sprite, label_pos_x + 100, label_pos_y + 50)
	end
end

function resetPosWhenJump(coorX, coorY )
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	local posx,posy = userData.getLocationPos()
	for i,v in pairs(m_arrEventData) do
		label_start_x = math.floor(i/10000)
		label_start_y = i%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		ObjectManager.setObjectPos(v.sprite, label_pos_x + 100, label_pos_y + 50)
	end
end

local function eventDisplay(data  )
	local wid = tonumber(data[2])
	
	local event_id = tonumber(data[3])
	-- 地表事件 Tb_user_field_event
	-- /** 地表事件(卡包)*/
	-- int FIELD_EVENT_CARD = 1;
	-- /** 地表事件(经验)*/
	-- int FIELD_EVENT_EXP = 2;
	-- /** 地表事件(贼兵)*/
	-- int FIELD_EVENT_THIEF = 3;
	local event_type = tonumber(data[1])
	if m_arrEventData[wid] and m_arrEventData[wid].sprite then
		m_arrEventData[wid].sprite:removeFromParentAndCleanup(true)
		m_arrEventData[wid].sprite = nil
	end

	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	if not locationX or not locationXPos then return end
	local pEventSprite = nil
	local picName = nil
	local function addEffect(event_type )
		if pEventSprite then
			local sprite = nil
			if event_type == GROUND.FIELD_EVENT_CARD then
				CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/kabao.ExportJson")
				sprite = CCArmature:create("kabao")
			else
				CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jingyanshu.ExportJson")
				sprite = CCArmature:create("jingyanshu")
			end
			pEventSprite:addChild(sprite, -2)
			sprite:getAnimation():playWithIndex(0)
		end
	end
	if event_type == GROUND.FIELD_EVENT_CARD then
		picName = {
			"dibiao_kapai1.png",
			"dibiao_kapai2.png",
			"dibiao_kapai3.png",
			"dibiao_kapai4.png"}
		pEventSprite = ImageView:create()
		pEventSprite:loadTexture(picName[event_id%10], UI_TEX_TYPE_PLIST)
		addEffect(event_type )
	elseif event_type == GROUND.FIELD_EVENT_EXP then
		picName = {
			"dibiao_jingyanbai.png",
			"dibiao_jingyanlv.png",
			"dibiao_jingyanlan.png",
			"dibiao_jingyanzi.png",
			"dibiao_jingyanjing.png"}
		pEventSprite = ImageView:create()
		local id = event_id%10
		if id == 0 then
			id = 1
		end
		pEventSprite:loadTexture(picName[id], UI_TEX_TYPE_PLIST)
		addEffect(event_type )
	elseif event_type == GROUND.FIELD_EVENT_THIEF then
		-- picName = {"dibiao_mucai.png","dibiao_shicai.png","dibiao_tiekuang.png","dibiao_niangshi.png"}
		-- picName = {
		-- 	"dibiao_mucai.png"
		-- }
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/zeibing.ExportJson")
		pEventSprite = CCArmature:create("zeibing")
		pEventSprite:getAnimation():playWithIndex(0)
		-- pEventSprite:loadTexture(picName[1], UI_TEX_TYPE_PLIST)
		-- pEventSprite:setAnchorPoint(cc.p(0.5, pEventSprite:getContentSize().width/4/pEventSprite:getContentSize().height))
	end
	-- 
	local end_x = math.floor(wid/10000)
	local end_y = wid%10000
	local x, y = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, end_x,end_y  )
	if not m_arrEventData[wid] then
		m_arrEventData[wid] = {}
	end
	m_arrEventData[wid].sprite = pEventSprite
	m_arrEventData[wid].event_id = event_id
	m_arrEventData[wid].event_type = event_type
	ObjectManager.addObject(GROUND_EVENT,m_arrEventData[wid].sprite, true, x+100, y+50 )
end

function eventChange( )
	local event =GroundEventData.getWorldEvent()
	for i,v in pairs(m_arrEventData) do
		if v.sprite then
			v.sprite:removeFromParentAndCleanup(true)
			MapResidence.setIconVisible( i, true )
		end
	end
	m_arrEventData = {}

	if event then
		for i ,v in pairs(event) do
			eventDisplay(v)
			MapResidence.setIconVisible( tonumber(v[2]), false )
		end
	end
end

function remove( )
	for i,v in pairs(m_arrEventData) do
		if v.sprite then
			v.sprite:removeFromParentAndCleanup(true)
			MapResidence.setIconVisible( i, true )
		end
	end
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/zeibing.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/kabao.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/jingyanshu.ExportJson")
	m_arrEventData = nil
	UIUpdateManager.remove_prop_update(dbTableDesList.user_world_event.name, dataChangeType.add, GroundEvent.eventChange)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_world_event.name, dataChangeType.update, GroundEvent.eventChange)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_world_event.name, dataChangeType.remove, GroundEvent.eventChange)
end

function create( )
	m_arrEventData = {}
	ObjectManager.addObjectCallBack(GROUND_EVENT, resetPosWhenMove, resetPosWhenJump)
	UIUpdateManager.add_prop_update(dbTableDesList.user_world_event.name, dataChangeType.add, GroundEvent.eventChange)
	UIUpdateManager.add_prop_update(dbTableDesList.user_world_event.name, dataChangeType.update, GroundEvent.eventChange)
	UIUpdateManager.add_prop_update(dbTableDesList.user_world_event.name, dataChangeType.remove, GroundEvent.eventChange)
	eventChange()
end



-- function eventRemove(packet )
-- 	local wid = packet.wid
-- 	if m_arrEventData[wid] then
-- 		if m_arrEventData[wid].sprite then
-- 			m_arrEventData[wid].sprite:removeFromParentAndCleanup(true)
-- 		end
-- 		m_arrEventData[wid] = nil
-- 	end
	
-- end