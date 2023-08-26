-- objectNewGuideObject
-- 新手引导在地图要放的东西
module("ObjectNewGuideObject", package.seeall)
local mObject = {}

function resetPosWhenMove( )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	for i,v in pairs(mObject) do
		label_start_x = math.floor(i/10000)
		label_start_y = i%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		ObjectManager.setObjectPos(v, label_pos_x + 100, label_pos_y + 50)
	end
end

function resetPosWhenJump(coorX, coorY )
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	local posx,posy = userData.getLocationPos()
	for i,v in pairs(mObject) do
		label_start_x = math.floor(i/10000)
		label_start_y = i%10000
		label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
		ObjectManager.setObjectPos(v, label_pos_x + 100, label_pos_y + 50)
	end
end

function create(wid,  imageName)
	removeObjectByWid( wid )
	local widx = math.floor(wid/10000)
	local widy = wid%10000
	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local x, y = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, widx,widy  )
	local sprite = cc.Sprite:create(imageName)
	ObjectManager.addObject(NEW_GUIDE_OBJECT, sprite, false, x+100, y+50 )
	ObjectManager.addObjectCallBack(NEW_GUIDE_OBJECT, setPosWhenMove, setPosWhenMove)
	mObject[wid] = sprite
	mObject[wid]:setPosition(cc.p(x+100,y+50))
end

function removeAllObject( )
	for i, v in pairs(mObject) do
		v:removeFromParentAndCleanup(true)
	end
	mObject = {}
end

function removeObjectByWid( wid )
	if mObject[wid] then
		mObject[wid]:removeFromParentAndCleanup(true)
		mObject[wid] = nil
	end
end