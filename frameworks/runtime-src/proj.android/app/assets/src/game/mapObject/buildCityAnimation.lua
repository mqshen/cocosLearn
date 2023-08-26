--建城或者建造要塞的动画
module("BuildCityAnimation", package.seeall)
local mAnimation = {}
local scale = 0.5
function resetPosWhenMove( )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	for i,v in pairs(mAnimation) do
		label_start_x = math.floor(i/10000)
		label_start_y = i%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		-- label_pos_x = posx + ((label_start_x - coorX) + (label_start_y - coorY)) * 0.5 * 200
		-- label_pos_y = posy + ((label_start_y - coorY) - (label_start_x - coorX)) * 0.5 * 100
		ObjectManager.setObjectPos(v, label_pos_x + 100, label_pos_y + 50)
		v:setScale(scale)
	end
end

function resetPosWhenJump(coorX, coorY )
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	local posx,posy = userData.getLocationPos()
	for i,v in pairs(mAnimation) do
		label_start_x = math.floor(i/10000)
		label_start_y = i%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		-- label_pos_x = posx + ((label_start_x - coorX) + (label_start_y - coorY)) * 0.5 * 200
		-- label_pos_y = posy + ((label_start_y - coorY) - (label_start_x - coorX)) * 0.5 * 100
		ObjectManager.setObjectPos(v, label_pos_x + 100, label_pos_y + 50)
		v:setScale(scale)
	end
end

function create( wid)
	-- if mAnimation[wid] then
		removeAnimationByWid(wid)
	-- end
	local widx = math.floor(wid/10000)
	local widy = wid%10000
	local viewstr = mapData.getBuildingView(widx, widy)
	if not viewstr then return end
	if viewstr ~= CityComponentType.getFengchengView() and viewstr ~= CityComponentType.getYaosaiView() then return end

	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local x, y = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, widx,widy  )
    
	local armature = nil--CCArmature:create("jianzaozhong")
	if viewstr == CityComponentType.getFengchengView() then
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jianzaofencheng.ExportJson")
		armature = CCArmature:create("jianzaofencheng")
	elseif viewstr == CityComponentType.getYaosaiView() then 
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jianzaozhong.ExportJson")
		armature = CCArmature:create("jianzaozhong")
	else
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jianzaozhong.ExportJson")
		armature = CCArmature:create("jianzaozhong")
	end

	armature:getAnimation():playWithIndex(0)
	mAnimation[wid] = armature
	-- armature:setPosition(cc.p(panel:getContentSize().width/2,panel:getContentSize().height/2))
	-- panel:addChild(armature)
	-- ObjectManager.addObject(BUILD_ANIMATION,mAnimation[wid], true, x+100, y+50 )
	mAnimation[wid]:setScale(scale)
	map.getInstance():addChild(mAnimation[wid])
	mAnimation[wid]:setPosition(cc.p(x+100,y+50))
	-- ObjectManager.addObjectCallBack(BUILD_ANIMATION, resetPosWhenMove, resetPosWhenJump)
end

function removeAnimationByWid( wid )
	if mAnimation[wid] then
		mAnimation[wid]:removeFromParentAndCleanup(true)
		mAnimation[wid] = nil
	end
end

function removeAll( )
	for i, v in pairs(mAnimation) do
		v:removeFromParentAndCleanup(true)
	end
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/jianzaofencheng.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/jianzaozhong.ExportJson")
	mAnimation = {}
end