-- battleAnimationController.lua
--新版动画战报
module("BattleAnimationController", package.seeall)
local isStop = nil --是否停止ai
-- local isPause = nil
local handler = {}
local arrowHandler = {}
local gridToArmyData = {} --格子里面保存着每个兵的位置
local closeFun = nil
-- local armyCoord = {} --每个兵的格子位置
--dead 是否已经挂了
--judgeFist 是否先进行移动判断
--armyType
--activity 是否可以移动
--wid 坐标
--isSelf 是否己方部队
--areaX, areaY 攻击距离
--position 战斗中的位置，0,1,2,3,4,5,6,7
--targetIndex 目标 这个值在armyLeaderInfo表示，当前固定不再走动时才会设置targetIndex
--targetWid  目标wid
--speed 速度
--lastWid 前一次动作的wid
--armyleader 该兵对应的leader的index
-- effectiveCount , lastEffectiveCount 当前有效人数， 上次有效人数
local armyInfo  = {}
local armyLeaderInfo = {}
local battleBatchNode = nil

local armyCountData = {}

local mLayer = nil
local m_isNoResult = nil --是否不再战斗结束后弹出结算界面
local m_isEndAnalisy = nil
local m_endAnimationName = nil
-- local mWidget = nil

local gridWidth = 131 --行
local gridHeight = 75 --列
local areaUp = 1
local areaDown = gridWidth
local areaLeft = 1
local areaRight = gridHeight
local m_speed = 1

local m_frame_index = 0 --本场战斗的进行到第几帧
local m_frame_callFunc = {} --本场战斗第n帧对应要处理那些函数

local forbidAreaHeight = nil--2*config.getWinSize().height/3 --不能走的区域

local heroData = nil
local seconds_frame = 1/26 --一帧需要多少秒

local midX = gridWidth
local midY = math.floor(gridHeight/2)+1

local _width = 30
local _height = 8
local angel = 10

local m_scale = 1.2*config.getWinSize().width/(_width*gridHeight)
local m_openDir = nil --是否不经过文字战报界面直接打开

local arrowArmyImageName = {}
arrowArmyImageName["enemy_1_1_attack_5.png"] = 1
arrowArmyImageName["enemy_1_2_attack_5.png"] = 1
arrowArmyImageName["player_1_1_attack_5.png"] =1
arrowArmyImageName["player_1_2_attack_5.png"] = 1

local formation = {
	[3] = {math.floor(10*gridWidth/12), math.floor(3*(gridHeight-1)/8/2)},
	[2] = {math.floor(9*gridWidth/12), math.floor(5*(gridHeight-1)/8/2)},
	[1] = {math.floor(8*gridWidth/12), math.floor(7*(gridHeight-1)/8/2)},
	[4] = {math.floor(5*gridWidth/12), math.floor(9*(gridHeight-1)/8/2+1)},
	[5] = {math.floor(4*gridWidth/12), math.floor(11*(gridHeight-1)/8/2+1)},
	[6] = {math.floor(3*gridWidth/12), math.floor(13*(gridHeight-1)/8/2+1)},

	-- [3] = {midX, math.floor((gridHeight-1)/6/2)},
	-- [2] = {midX, math.floor(3*(gridHeight-1)/6/2)},
	-- [1] = {midX, math.floor(5*(gridHeight-1)/6/2)},
	-- [4] = {midX, math.floor(7*(gridHeight-1)/6/2+1)},
	-- [5] = {midX, math.floor(9*(gridHeight-1)/6/2+1)},
	-- [6] = {midX, math.floor(11*(gridHeight-1)/6/2+1)},
}

local armyRootLayer = nil
local frameRootLayer = nil
local armyRootLayerxx = nil
local iconLayer = nil
local three_DLayer = nil
local newGuideFistLine = nil
local newGuideSecondLine = nil

function cannotTouchWhenNewGuide(x,y )
	if not mLayer then
		return false
	end
	local temp_widget = mLayer:getWidgetByTag(999)
	if temp_widget then
		local panel_down = tolua.cast(temp_widget:getChildByName("Panel_down"),"Layout")
		if panel_down:hitTest(cc.p(x,y)) then
			return true
		end

		local confirm_close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
		if confirm_close_btn:hitTest(cc.p(x,y)) then
			return true
		end
	end
	return false
end

-- 记录战场的武将在哪个位置，依次是3，2，1，4，5，6
local formationIndex = {}

-- 记录位置对应的武将
local formationHeroToPos = {}

local function fixAreaX(x )
	if x < areaUp then
		return areaUp
	elseif x > areaDown then
		return areaDown
	end
	return x
end

local function fixAreaY( y )
	if y < areaLeft then
		return areaLeft
	elseif y > areaRight then
		return areaRight
	end
	return y
end


local function setSpeed( )
	if m_speed == 1 then
		m_speed = m_speed + 1
	else
		m_speed = 1
	end
end

local function getRightCoord( x, y, coorx, coory )
	if coorx < areaUp or coorx > areaDown or coory < areaLeft or coory > areaRight then--or y > forbidAreaHeight then
		return false
	end
	return coorx, coory
end

-- 因为用时间做ai的控制会导致不准确，所以用帧数来控制每帧对应的逻辑
local function everyFrame( )
	handler=scheduler.create(function (  )
		if isStop then
			-- for i , v in ipairs(handler) do
				scheduler.remove(handler)
				handler = nil
				return
			-- end
		end
		m_frame_index = m_frame_index + 1
		if m_frame_callFunc[m_frame_index] then
			for i,v in ipairs(m_frame_callFunc[m_frame_index]) do
				v.callFunc(v.index, v.coorx, v.coory)
			end
		end
	end,0)
end

local function playAnimationSequence(index, sequenceIndex )
	local actionTable = {}
	armyInfo[index].object:stopActionByTag(index)
	local sequenceArr = sequenceDefined[sequenceIndex]
	local count = nil
	local countTime = nil
	if armyInfo[index].action == "die" or armyInfo[index].action == "attack" then
		count = 1
		countTime = 1
	else
		count = math.random(1,#sequenceArr)
		countTime = math.random(1,#sequenceArr)
	end

	for i=1,  #sequenceArr do
		table.insert(actionTable, cc.CallFunc:create(function ( )
			armyInfo[index].object:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(sequenceArr[count].name))
			-- 弓兵要播放射箭的动画
			if armyInfo[index].armyType == 1 and armyInfo[index].action == "attack" and i== 6 then
				setAttackAction(armyInfo[index].uniqueId, armyInfo[index].targetIndex )
			end

			if armyInfo[index].action == "die" and i== #sequenceArr then
				armyInfo[index].object:setVisible(false)
				armyInfo[index].object:stopActionByTag(index)
			end

			count = count + 1
			if count > #sequenceArr then
				count = 1
			end
		end))

		countTime = countTime + 1
		if countTime > #sequenceArr then
			countTime = 1
		end
		table.insert(actionTable, cc.DelayTime:create(sequenceArr[countTime].time/m_speed))
	end

	local action = CCRepeatForever:create(animation.sequence(actionTable))
	action:setTag(index)
	armyInfo[index].object:runAction(action)
	armyInfo[index].animationName = sequenceIndex
end

local function playAnimationByTable( )
	table.insert(handler, scheduler.create(function ( )
		local name = nil
		for i, v in pairs(armyInfo) do
			if v.action == "base" or v.action == "leader" then
				if v.iswait then
					name = v.isOb.."_" ..v.action.."_".. v.direction.."_wait"
				else
					name = v.isOb.."_"..v.action.."_".. v.direction
				end
				if name ~= v.animationName then
					playAnimationSequence(i, name )
				end
			else
				if v.iswait then
					name = v.isOb.."_"..v.armyType.."_".. v.direction.."_" .."wait"
				else
					name = v.isOb.."_"..v.armyType.."_".. v.direction.."_" ..v.action
				end
				if name ~= v.animationName then
					playAnimationSequence(i, name )
				end
			end
		end
	end, 0.1))
end

-- 设置小型和中型头像显示的剩余兵力
local function setIconArmyCount(pos )
	tolua.cast(heroData[pos].small_icon:getChildByName("army_count"),"Label"):setText(armyLeaderInfo[pos*100+1].left_count)
	cardFrameInterface.set_army_count(heroData[pos].card, armyLeaderInfo[pos*100+1].left_count, nil)
end

-- 战报中的中型武将头像
local function initMidIcon( index)
	local herodata = armyLeaderInfo[index]
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_mid_item.json")

	local position_image = tolua.cast(temp_widget:getChildByName("position_image"),"ImageView")
	local position_image_name = ""
	local position = math.floor(index/100)
	local battle_id = BattlaAnimationData.getBattleId()
	local battleReport = reportData.getReport(battle_id)
	if not reportData.returnAttackOrDefend(battleReport ) then
		local reflect = {[7] =1, [6] = 2, [5] = 3, [4] = 4, [3] = 5, [2] = 6}
		position_image_name = ResDefineUtil.iconItem[reflect[position]]
	else
		position_image_name = ResDefineUtil.iconItem[position-1]
	end
	position_image:loadTexture(position_image_name, UI_TEX_TYPE_PLIST)

	local panel = tolua.cast(temp_widget:getChildByName("Panel_card"),"Layout")
	local card = cardFrameInterface.create_small_card(nil,herodata.heroid , false)
	if position <= 4 then 
        if battleReport.attack_advance then
            cardFrameInterface.doSetAdvancedDetail(card, battleReport.attack_advance[position][1], Tb_cfg_hero[herodata.heroid].quality+1,battleReport.attack_advance[position][2] == 1)
        end
    else
        if battleReport.defend_advance then
            cardFrameInterface.doSetAdvancedDetail(card, battleReport.defend_advance[position-4][1], Tb_cfg_hero[herodata.heroid].quality+1,battleReport.defend_advance[position-4][2] == 1)
        end
    end

	cardFrameInterface.set_lv_images(heroData[math.floor(index/100)].level,card)
	card:setAnchorPoint(cc.p(0,0))
	panel:addChild(card)
	temp_widget:setVisible(false)
	return temp_widget,card
end

-- 战报中的小型武将头像
local function initSmallIcon(index )
	local herodata = armyLeaderInfo[index]
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_small_item.json")
	-- local name = tolua.cast(temp_widget:getChildByName("name"),"Label")
	-- name:setText(Tb_cfg_hero[herodata.heroid].name)

	local armytype_image = tolua.cast(temp_widget:getChildByName("armytype"),"ImageView")
	local armytype_image_name = ""
	if herodata.armyType == 1 then
		armytype_image_name = ResDefineUtil.img_soldier_type[1]
	elseif herodata.armyType == 2 then
		armytype_image_name = ResDefineUtil.img_soldier_type[2]
	else
		armytype_image_name = ResDefineUtil.img_soldier_type[3]
	end
	armytype_image:loadTexture(armytype_image_name, UI_TEX_TYPE_PLIST)

	local panel = tolua.cast(temp_widget:getChildByName("Panel_icon"),"Layout")
	local icon = cardFrameInterface.create_mini_card(0, Tb_cfg_hero[herodata.heroid].heroid, false )
	if icon then
		panel:addChild(icon)
		icon:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height/2))
	end

	local image = tolua.cast(temp_widget:getChildByName("ImageView_548881_0_0_0_2_0_0"),"ImageView")
	local circle = tolua.cast(panel:getChildByName("ImageView_1042234"),"ImageView") --ImageView:create()
	circle:setAnchorPoint(cc.p(0.5,0.5))
	-- panel:addChild(circle)
	if herodata.isSelf then
		circle:loadTexture(ResDefineUtil.xintouxiang_yuankuang_1,UI_TEX_TYPE_PLIST)
		image:loadTexture(ResDefineUtil.zhanbao_lan_diban,UI_TEX_TYPE_PLIST)
	else
		circle:loadTexture(ResDefineUtil.xintouxiang_yuankuang_2 ,UI_TEX_TYPE_PLIST)
		image:loadTexture(ResDefineUtil.zhanbao_hong_diban,UI_TEX_TYPE_PLIST)
	end
	circle:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height/2))

	temp_widget:setVisible(true)
	return temp_widget
end

--寻找最近的敌方主将
local function getEnemyCoord(index )
	if not armyLeaderInfo[index] then return end
	local armyPositionMax = nil
	local armyPositionMin = nil
	local x, y = math.floor(armyLeaderInfo[index].wid/10000), armyLeaderInfo[index].wid%10000
	local targetX, targetY = nil, nil
	local pos = nil
	local len = nil
	local tmp_len = nil
	if armyLeaderInfo[index].position <= 4 then
		armyPositionMax = 8
		armyPositionMin = 5
	else
		armyPositionMax = 4
		armyPositionMin = 1
	end

	--如果有目标的时候就不再寻找新的目标
	if armyLeaderInfo[index].targetIndex then
		-- if not armyLeaderInfo[armyLeaderInfo[index].targetIndex].dead then
			-- local enemyWid = armyLeaderInfo[armyLeaderInfo[index].targetIndex].wid
			-- return math.floor(enemyWid/10000), enemyWid%10000, armyLeaderInfo[index].targetIndex
		if not armyInfo[armyLeaderInfo[index].targetIndex].dead then
			local enemyWid = armyInfo[armyLeaderInfo[index].targetIndex].wid
			return math.floor(enemyWid/10000), enemyWid%10000, armyLeaderInfo[index].targetIndex
		else
			armyInfo[index].targetIndex = nil
			if armyLeaderInfo[index] then
				armyLeaderInfo[index].targetIndex = nil
			end
		end
	end

	if armyLeaderInfo[index].effectiveTarget and #armyLeaderInfo[index].effectiveTarget>0 then
		local target = nil
		-- 弓
		if armyLeaderInfo[index].armyType == 1 then
			target = armyLeaderInfo[index].effectiveTarget[1]
		elseif armyLeaderInfo[index].armyType == 3 then
			target = armyLeaderInfo[index].effectiveTarget[#armyLeaderInfo[index].effectiveTarget]
		else
			target = armyLeaderInfo[index].effectiveTarget[math.random(1, #armyLeaderInfo[index].effectiveTarget)]
		end
		-- pos = target*100+1
		-- targetX = math.floor(armyLeaderInfo[pos].wid/10000)
		-- targetY = armyLeaderInfo[pos].wid%10000
		local data = {}
		for i, v in pairs(armyLeaderInfo[target*100+1].underIndex) do
			if not armyInfo[v].dead then
				table.insert(data, v)
			end
		end

		if #data == 0 then
			table.insert(data, target*100+1)
		end

		pos = data[math.random(1,#data)]
		targetX = math.floor(armyInfo[pos].wid/10000)
		targetY = armyInfo[pos].wid%10000
	end


	if targetX and targetY then
		armyLeaderInfo[index].targetIndex = pos
		armyInfo[index].targetIndex = pos
	end

	return targetX, targetY, pos
end

--从有效目标中平均选取一个敌军作为目标
local function getLeaderTarget( index )
	if not armyInfo[index] then return false end
	local armyPositionMax = nil
	local armyPositionMin = nil
	local x, y = math.floor(armyInfo[index].wid/10000), armyInfo[index].wid%10000
	local targetX, targetY = nil, nil
	local wid = nil
	local targetPos = nil
	local targetIndex = nil
	local data = {}
	if armyLeaderInfo[armyInfo[index].armyleader] then
		local effect_count = #armyLeaderInfo[armyInfo[index].armyleader].effectiveTarget

		local targetIndex = armyLeaderInfo[armyInfo[index].armyleader].effectiveTarget[index%effect_count+1]*100+1
		if targetIndex then
			-- 先找没有目标的敌人
			for i, v in ipairs(armyLeaderInfo[targetIndex].underIndex) do
				if not armyInfo[v].dead and not armyInfo[v].targetIndex then
					table.insert(data, v)
				end
			end

			-- 不能选取主将作为目标，因为主将是在所有人挂了之后才会挂，如果选择主将作为目标就会一堆人围着但是没打死
			-- table.insert(data, targetIndex)

			-- 如果敌人都有目标，那么在有目标的敌人中找
			if #data == 0 then
				for i, v in ipairs(armyLeaderInfo[targetIndex].underIndex) do
					if not armyInfo[v].dead then
						table.insert(data, v)
					end
				end
			end

			if #data > 0 then
				targetPos = data[math.random(1, #data)]

				wid = armyInfo[targetPos].wid
				targetX, targetY = math.floor(wid/10000), wid%10000

				return targetX, targetY,targetPos
			end
		end
	end

	return false
end

-- 寻找最近敌方目标
local function getNearestTarget(index )
	if not armyInfo[index] then return false end
	local armyPositionMax = nil
	local armyPositionMin = nil
	local x, y = math.floor(armyInfo[index].wid/10000), armyInfo[index].wid%10000
	local targetX, targetY = nil, nil
	local pos = nil
	local len = nil
	local tmp_len = nil
	if armyInfo[index].position <= 4 then
		armyPositionMax = 8
		armyPositionMin = 5
	else
		armyPositionMax = 4
		armyPositionMin = 1
	end

	for i, v in pairs(armyInfo) do
		if not v.dead and v.position >= armyPositionMin and v.position <=armyPositionMax then
			tmp_len = math.sqrt(math.pow(math.floor(armyInfo[i].wid/10000) - x, 2) + math.pow(armyInfo[i].wid%10000 - y, 2))
			if not len or tmp_len < len then
				len = tmp_len
				targetX = math.floor(armyInfo[i].wid/10000)
				targetY = armyInfo[i].wid%10000
				pos = i
			end
		end
	end
	return targetX, targetY, pos
end

--S1 跟随主将的移动
local function followLeader(index )
	if not armyInfo[index] then return false end
	if not armyInfo[index].armyleader then return false end
	local wid = armyInfo[armyInfo[index].armyleader].wid
	local lastWid = armyInfo[armyInfo[index].armyleader].lastWid
	if not lastWid then return false end
	if not wid then return false end
	local dtX = math.floor(wid/10000) - math.floor(lastWid/10000)
	local dtY = wid%10000 - lastWid%10000

	return math.floor(armyInfo[index].wid/10000) + dtX, armyInfo[index].wid%10000 + dtY
end

--获取下一步的真正格子
-- 第一第二个返回值表示下一个坐标，第三个表示发生战斗的位置， 第四个表示下一次是否会发生战斗
local function getBoundingCoord(info, x, y, targetX, targetY,index,pos )
	if math.abs(x - targetX) <= info.attackArea and math.abs(y - targetY) <= info.attackArea then
		return x, y,pos,false
	end

	local hangLeft, hangRight, dt = nil, nil, 1
	local lieUp, lieDown, dt_2 = nil, nil, 1
	local attackArea = info.attackArea
	if attackArea >= 10 then
		attackArea = 0
	end

	if targetX > x then
		hangLeft, hangRight = x+1, targetX--+attackArea
	elseif targetX < x then
		hangLeft, hangRight = x-1, targetX---attackArea
		dt = -1
	else
		hangLeft, hangRight = x,x---attackArea, x+attackArea
	end

	-- 先在正面尝试是否有可用位置
	if targetY > y then
		lieUp, lieDown = y+1, targetY--+attackArea
	elseif targetY < y then
		lieUp, lieDown = y-1, targetY---attackArea
		dt_2 = -1
	else
		lieUp, lieDown = y,y---attackArea, y--+attackArea
	end


	for i = lieUp, lieDown, dt_2 do
		for j= hangLeft, hangRight, dt do
			if not gridToArmyData[j*10000 + i] then
				if (math.abs(targetX - j) <= info.attackArea and math.abs(targetY - i) <= info.attackArea) then 
					return j,i,false,true
				elseif targetX == j and targetY >= i and gridToArmyData[j*10000 + i+1] then
					return j,i,false,true
				elseif targetX == j and targetY < i and gridToArmyData[j*10000 + i-1] then
					return j,i,false,true
				elseif targetY == i and targetX >= j and gridToArmyData[(j+1)*10000 + i] then
					return j,i,false,true
				elseif targetY == i and targetX < j and gridToArmyData[(j-1)*10000 + i] then
					return j,i,false,true
				else
					return j,i,false,false
				end
			end
		end
	end

	-- 再在背面寻找是否有可用位置

	if targetX > x then
		hangLeft, hangRight = targetX+attackArea,targetX+attackArea
	elseif targetX < x then
		hangLeft, hangRight = targetX-attackArea,targetX-attackArea
		dt = -1
	else
		hangLeft, hangRight = x-attackArea, x+attackArea
	end

	if targetY > y then
		lieUp, lieDown = targetY+attackArea, targetY+attackArea
	elseif targetY < y then
		lieUp, lieDown = targetY-attackArea, targetY-attackArea
		dt_2 = -1
	else
		lieUp, lieDown = y-attackArea, y+attackArea
	end

	for i = lieUp, lieDown, dt_2 do
		for j= hangLeft, hangRight, dt do
			if not gridToArmyData[j*10000 + i] then
				if math.abs(targetX - j) <= info.attackArea and math.abs(targetY - i) <= info.attackArea then 
					return j,i,false,true
				else
					return j,i,false,false
				end
			end
		end
	end


	return x, y,false,false
end

-- 拿旗的骑兵的ai，优先搜索前面有目标时停下来
-- aitype 1 前进 2坐标 3主将 4 最近目标 99 没有目标
-- wid
local function armyWithFlagAI(index, data )
	if not armyLeaderInfo[index] then return end
	if armyLeaderInfo[index].dead then return end
	local x, y = math.floor(armyLeaderInfo[index].wid/10000), armyLeaderInfo[index].wid%10000
	local targetX, targetY,targetWid, pos = nil,nil,nil,nil
	--先判断攻击范围是否有敌军
	-- targetX, targetY,targetWid, pos = enemyInArea(index )

	--当前方没有敌军
	if not targetX and not targetY then
		if not armyLeaderInfo[index].activity then return false end
		if not data.aiType then
			return false
		elseif data.aiType == 3 or data.aiType == 4 then
			if data.aiType == 3 then
				targetX, targetY,pos = getEnemyCoord(index )
			else
				targetX, targetY,pos = getEnemyCoord(index )
				-- targetX, targetY,pos = getNearestTarget(index )
			end

			if not targetX or not targetY or not pos then 
				return false 
			end
		end
	else
		return targetX, targetY,targetWid,pos
	end
	return getBoundingCoord( armyLeaderInfo[index], x, y, targetX, targetY,index,pos )
end

-- 变阵 1
-- 阵地作战 2
-- 散开 3
-- 冲锋 4
-- 自由作战 5

-- S1	跟随	根据所属部队的AI指令进行移动				
-- S2	攻击	当攻击判定格出现敌军后进行攻击				
-- S3	索敌	搜索最近的目标并且接近，通常情况下个体的AI优先级低于部队指令				
-- S4	静止					

local function armyNormalAI( index,data )
	if armyInfo[index].dead then return false end
	local x, y = math.floor(armyInfo[index].wid/10000), armyInfo[index].wid%10000
	local targetX, targetY, targetWid, pos = nil,nil,nil,nil
	if data.aiType == 2 or data.aiType == 3 or data.aiType == 4 or data.aiType == 5 then
		-- s2
		-- targetX, targetY,targetWid,pos = enemyInArea(index )
		--当攻击范围没有目标，执行其他指令
		-- if not armyLeaderInfo[armyInfo[index].armyleader].activity then return end
		if not targetX and not targetY then
			-- if not armyLeaderInfo[armyInfo[index].armyleader].activity then return false end
			-- 当执行的是s5
			-- if data.aiType == 5 then
				if armyInfo[index].targetIndex and not armyInfo[armyInfo[index].targetIndex].dead then
					targetX, targetY, pos = math.floor(armyInfo[armyInfo[index].targetIndex].wid/10000),armyInfo[armyInfo[index].targetIndex].wid%10000,armyInfo[index].targetIndex
					-- 当攻击距离不足时，只有目标在攻击距离之内才会攻击
					if not armyLeaderInfo[armyInfo[index].armyleader].activity then
						if math.abs(x - targetX) <= armyInfo[index].attackArea and math.abs(y - targetY) <= armyInfo[index].attackArea then
							return x, y,pos,false
						end
						return false
					end
				else
					if not armyLeaderInfo[armyInfo[index].armyleader].activity then
						return
					end
					armyInfo[index].targetIndex = nil
					targetX, targetY, pos= getLeaderTarget(index) 
				end

				if not targetX and not targetY then
					return false
				else
					if pos then
						armyInfo[index].targetIndex = pos
					else
						return false
					end
				end
			-- 其他的都是跟随主将
			-- else
				-- return
				-- targetX, targetY = followLeader(index )
				-- if not gridToArmyData[targetX*10000 + targetY] or gridToArmyData[targetX*10000 + targetY] ==index  then
				-- 	return targetX, targetY
				-- end
			-- end
		else
			return targetX, targetY, targetWid, pos
		end
	else

	end

	return getBoundingCoord(armyInfo[index], x, y, targetX, targetY, index,pos )
end

-- B1	变阵	部队进行阵型变化		用于表示战前buff和一些效果的展示
-- B2	阵地作战	保持阵型等待		
-- B3	散开	小兵间的最小间距不小于XXX，并缓慢向前移动		
-- B4	冲锋	部队朝目标地点移动，目标是地点而不是对方士兵		
-- B5	自由作战	跟随主将寻找一个部队的士兵进行战斗		
-- 拿旗的骑兵的ai，优先搜索前面有目标时停下来
-- aitype 1 前进 2坐标 3主将 4 最近目标 99 没有目标
local function differentAI(index)
	if armyLeaderInfo[index].aiType == 4 then
		return 2
	elseif armyLeaderInfo[index].aiType == 3 then
		-- return nil, nil, distanceAmongArmy(index, 5, nil, nil, nil )
		return 3
	elseif armyLeaderInfo[index].aiType == 5 then
		return 3
	elseif armyLeaderInfo[index].aiType == 2 then
		return false
	end
end

-- posX,posY 参考点的实际坐标x,y
-- coorX,coorY 参考点的行列坐标
-- i,j 想要获取的点的行列坐标
function getMapSpritePos(posX,posY, coorX,coorY, i,j, offsetX, offsetY  )
	-- width 113 heigh =151
	local x,y = offsetX or 200, offsetY or 100
	-- return posX+ ((i- coorX)+(j - coorY))*x,
	-- 	   posY+ y*((j-coorY)-(i-coorX))
	return posX+(j-coorY)*x,
			posX+(coorX-i)*y
end

function getMapRealPos( nodex, nodey )
	local nodePoint = three_DLayer:convertToWorldSpace(cc.p(nodex, nodey))

	local px, py = config.countWorldSpace(nodePoint.x, nodePoint.y, angel)
	local nodePoint = armyRootLayer:convertToNodeSpace(cc.p(nodePoint.x, py))
	return px,py,nodePoint.x, nodePoint.y
end



--获取武将的对象，包括widget
function getHeroTarget( heroPos)
	if not heroPos then
		print(">>>>>>>>>>>>>>>>>>>>>>>>heroPos is nil")
		return false
	end

	if not heroData then
		return false
	end
	return heroData[heroPos]
end

function getInstance( )
	return frameRootLayer
end

function getArmyLayer( )
	return armyRootLayer
end

local function clearBattle( )
	
	BattleResultSum.remove_self()
	BattleAnimation.initSpeed()
	m_speed = 1
	for i,v in ipairs(handler) do
		scheduler.remove(v)
	end
	m_frame_index = 0
	m_frame_callFunc = {}
	handler = {}

	for i, v in pairs(arrowHandler) do
		v.arrow:removeFromParentAndCleanup(true)
		scheduler.remove(v.timer)
	end
	arrowHandler = {}
	local temp_widget = mLayer:getWidgetByTag(999)
	temp_widget:removeFromParentAndCleanup(true)
	armyRootLayer:removeFromParentAndCleanup(true)
	-- armyRootLayerxx:removeFromParentAndCleanup(true)
	frameRootLayer:removeFromParentAndCleanup(true)
	iconLayer:removeFromParentAndCleanup(true)
	armyRootLayer = nil
	-- armyRootLayerxx = nil
	frameRootLayer = nil
	iconLayer = nil

	three_DLayer = nil

	battleBatchNode = nil

	three_DLayer = nil
	m_isEndAnalisy = nil
	m_endAnimationName = nil

	battleBatchNode = nil
	armyInfo = {}
	gridToArmyData = {}
	armyLeaderInfo = {}
	formationHeroToPos = {}
	formationIndex = {}
	armyCountData = {}

	if heroData then
		heroData = nil
	end

	isStop = nil
	-- isPause = true
	BattleAnalyse.remove()
end

function resumeBattle(  )
	clearBattle()
	-- isPause = false
	init()
    BattleAnalyse.analyseAnimation()
end

function do_remove_self( )
	if mLayer then
		clearBattle( )
		m_isNoResult = nil
		newGuideFistLine = nil
		newGuideSecondLine = nil
		-- isPause = nil
		mLayer:removeFromParentAndCleanup(true)
		mLayer = nil
		armyRootLayerxx = nil
		uiManager.remove_self_panel(uiIndexDefine.BATTLA_ANIMATION_UI)
		local textureCache = CCTextureCache:sharedTextureCache()
		textureCache:removeTextureForKey("test/res_single/battle_background.png")
		textureCache:removeTextureForKey("test/res_single/battle_fog.png")
		textureCache:removeTextureForKey("test/res_single/battle_effect.png")
		textureCache:removeTextureForKey("test/res_single/blue_battle_effect.png")
		LSound.stopMusic()
		-- LSound.musicStateCallback(2 )
		LSound.playMusic("main_bgm1")
		if m_openDir then
			OpenBattleAnimation.remove()
		end
		m_openDir = nil
		-- LSound.playMusic("main_bgm2")
		if closeFun then
			closeFun = nil
			PracticeReportData.playePracticeReportCallBack()
		end
	end
end

function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.BATTLA_ANIMATION_UI,mLayer,do_remove_self)
end

function setEndAnalisy(animationName )
	m_endAnimationName = animationName
	m_isEndAnalisy = true

	if frameRootLayer then
		frameRootLayer:runAction(animation.sequence({cc.DelayTime:create(5/m_speed),cc.CallFunc:create(function ( )
			if not BattleResultSum.getInstance() then
				playEndAnimation( )
			end
		end)}))
	end

	-- 如果这场战斗是平局，那么直接在解析完了就结束
	if m_isEndAnalisy and m_endAnimationName == "pingju" then
		playEndAnimation(  )
		return
	end

	for i, v in pairs(armyLeaderInfo) do
		-- if not v.dead then
		-- 	return
		-- end
		if m_endAnimationName == "huosheng" and not v.isSelf then
			if not v.dead then
				return
			end

			if v.dead then
				if v.deadCount > 0 then
					return
				end
			end
		end

		if m_endAnimationName == "zhanbai" and v.isSelf then
			if not v.dead then
				return
			end

			if v.dead then
				if v.deadCount > 0 then
					return
				end
			end
		end
	end

	playEndAnimation(  )
end

local function effectiveTargetCount(heroPos )
	local tmp_armyinfo = BattlaAnimationData.getArmyInfo()
	local hit_range = armyLeaderInfo[heroPos*100+1].hit_range --Tb_cfg_hero[tmp_armyinfo[heroPos].heroid].hit_range

	-- 实际中的位置 
	local realPos = formationIndex[heroPos]
	local effectiveCount = 0
	local canUsehit_range = hit_range
	local effectiveTarget = {}
	if realPos >=1 and realPos <=3 then
		for i=realPos-1, realPos-hit_range, -1 do
			if i<1 then
				break
			else
				if formationHeroToPos[i] and not armyLeaderInfo[formationHeroToPos[i]*100+1].dead then
					canUsehit_range = canUsehit_range - 1
					if canUsehit_range <=0 then
						break
					end
				end
			end
		end

		if canUsehit_range > 0 then
			local index = 4
			for i=4, 6 do
				if formationHeroToPos[i] and not armyLeaderInfo[formationHeroToPos[i]*100+1].dead then
					index = i
					break
				end
			end

			for i=index , index+canUsehit_range-1 do
				if formationHeroToPos[i] and not armyLeaderInfo[formationHeroToPos[i]*100+1].dead then
					effectiveCount = effectiveCount + 1
					table.insert(effectiveTarget, formationHeroToPos[i])
				end

				if effectiveCount >=3 then
					break
				end
			end
		end
		return effectiveCount, effectiveTarget
	else
		for i=realPos-1, realPos-hit_range, -1 do
			if i<4 then
				break
			else
				if formationHeroToPos[i] and not armyLeaderInfo[formationHeroToPos[i]*100+1].dead then
					canUsehit_range = canUsehit_range - 1
					if canUsehit_range <=0 then
						break
					end
				end
			end
		end

		if canUsehit_range > 0 then
			local index = 1
			for i=1, 3 do
				if formationHeroToPos[i] and not armyLeaderInfo[formationHeroToPos[i]*100+1].dead then
					index = i
					break
				end
			end

			for i=index , index+canUsehit_range-1 do
				if formationHeroToPos[i] and not armyLeaderInfo[formationHeroToPos[i]*100+1].dead then
					effectiveCount = effectiveCount + 1
					table.insert(effectiveTarget, formationHeroToPos[i])
				end

				if effectiveCount >=3 then
					break
				end
			end
		end
		return effectiveCount,effectiveTarget
	end
end

function realCount( num )
	-- if pos <=4 then
	local count = math.floor(math.pow(math.log10(num+1),2.3)*2)
	if count > 50 then
		return 50
	else
		if num > 0 and count == 0 then
			return 2
		end 
		return count
	end
end

-- 打开战斗结算界面
function openBattleResult(  )
	if not m_isNoResult then
		BattleResultSum.create(mLayer)
	end
end

-- 任何情况下都会打开战斗结算界面
function openBattleResultAnyWay( )
	BattleResultSum.create(mLayer)
end

function init( )
	LSound.playMusic("seige_bgm")
	require("game/battle/battleFormationDefined")
	-- if mLayer then return end

	local offsetY = 20*_height*m_scale

	local touchLayer = Layout:create()
	touchLayer:setContentSize(CCSize(config.getWinSize().width,config.getWinSize().height))
	touchLayer:setTouchEnabled(true)
	mLayer:addWidget(touchLayer)

	three_DLayer = Layout:create()
	three_DLayer:setContentSize(CCSize(1,1))
	three_DLayer:setPosition(cc.p(config.getWinSize().width/2,-offsetY))
	three_DLayer:setScale(m_scale)
	mLayer:addWidget(three_DLayer)

	--放小兵的层
	armyRootLayer = Layout:create()
	armyRootLayer:setContentSize(CCSize(1,1))
	armyRootLayer:setPosition(cc.p(config.getWinSize().width/2,-offsetY))
	armyRootLayer:setScale(m_scale)
	mLayer:addWidget(armyRootLayer)

	battleBatchNode = CCSpriteBatchNode:create("gameResources/battle/battle_dir_1_2.png")
	armyRootLayer:addChild(battleBatchNode)
	-- battleBatchNode = armyRootLayer

	local orbit = CCOrbitCamera:create(0.1,1, 0, 0,-angel, 90, 0)
	three_DLayer:runAction(orbit)

	

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_01.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	mLayer:addWidget(temp_widget)

	iconLayer = Layout:create()
	iconLayer:setContentSize(CCSize(1,1))
	iconLayer:setPosition(cc.p(config.getWinSize().width/2,0))
	iconLayer:setScale(config.getgScale())
	mLayer:addWidget(iconLayer)

	--放全屏特效的层
	frameRootLayer = Layout:create()
	frameRootLayer:ignoreAnchorPointForPosition(false)
	frameRootLayer:setAnchorPoint(cc.p(0.5,0.5))
	frameRootLayer:setPosition(cc.p(config.getWinSize().width/2,config.getWinSize().height/2))
	-- cc.Director:getInstance():getRunningScene():addChild(frameRootLayer,999,999)
	frameRootLayer:setScale(m_scale)
	mLayer:addWidget(frameRootLayer)

	local back =cc.Sprite:create("test/res_single/battle_fog.png")
	back:setAnchorPoint(cc.p(0.5,0))
	armyRootLayer:addChild(back)
	local temp_scale = config.getWinSize().height/back:getContentSize().height/m_scale
	back:setScale(temp_scale)
	local fadein = animation.spawn({CCFadeIn:create(5), CCScaleTo:create(5,1.2*temp_scale)})
	local fadeout = animation.spawn({CCFadeOut:create(5), CCScaleTo:create(5,1.5*temp_scale)})
	local call = cc.CallFunc:create(function ( )
		back:setScale(temp_scale)
	end)

	back:runAction(CCRepeatForever:create(animation.sequence({fadein,fadeout ,call})))
	

	-- 按照全屏匹配ui
	-- 两个血条
	local nodePoint = temp_widget:convertToNodeSpace(cc.p(config.getWinSize().width,config.getWinSize().height))
	local nodePoint_down = temp_widget:convertToNodeSpace(cc.p(config.getWinSize().width,0))
	local panel_left = tolua.cast(temp_widget:getChildByName("Panel_left"),"Layout")
	panel_left:setAnchorPoint(cc.p(0,1))
	panel_left:setPositionY(nodePoint.y)

	forbidAreaHeight = temp_widget:convertToWorldSpace(cc.p(panel_left:getPositionX(), panel_left:getPositionY()- panel_left:getSize().height)).y

	local panel_right = tolua.cast(temp_widget:getChildByName("Panel_right"),"Layout")
	panel_right:setAnchorPoint(cc.p(0,1))
	panel_right:setPositionY(nodePoint.y)

	--下面的结算，快进等ui
	local panel_down = tolua.cast(temp_widget:getChildByName("Panel_down"),"Layout")
	panel_down:setAnchorPoint(cc.p(1,0))
	panel_down:setPosition(nodePoint_down)

	local speed_Label = tolua.cast(panel_down:getChildByName("speed_label"),"Label")

	-- 速度按钮
	local speed_btn = tolua.cast(panel_down:getChildByName("speed_button"),"Button")
	speed_btn:setTouchEnabled(true)
	speed_btn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			speed_Label:setText("X "..BattleAnimation.setSpeed())
			setSpeed()
		end
	end)

	-- 武将详情按钮
	local detail_Button = tolua.cast(panel_down:getChildByName("detail_Button"),"Button")
	detail_Button:setTouchEnabled(true)
	detail_Button:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			for i, v in pairs(heroData) do
				v.small_icon:setVisible(not v.small_icon:isVisible())
				v.mid_icon:setVisible(not v.mid_icon:isVisible())
			end
		end
	end)

	-- 结算按钮
	local sub_Button = tolua.cast(panel_down:getChildByName("sub_Button"),"Button")
	sub_Button:setTouchEnabled(true)
	sub_Button:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			openBattleResult()
		end
	end)

	--关闭按钮
	local confirm_close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	confirm_close_btn:setAnchorPoint(cc.p(1,1))
	confirm_close_btn:setPosition(nodePoint)
	confirm_close_btn:setTouchEnabled(true)
	confirm_close_btn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)

	local image = tolua.cast(temp_widget:getChildByName("ImageView_810164"), "ImageView")
	image:setPositionY(nodePoint.y)

	local tmp_armyinfo = BattlaAnimationData.getArmyInfo()

	local att_armyCount = 0
   	local def_armyCount = 0
   	local att_armyAfterCount = 0
   	local def_armyAfterCount = 0
    for i, v in pairs(tmp_armyinfo) do
        if i<=4 then
            -- att_armyAfterCount = att_armyAfterCount + v.armyAfter
            att_armyCount = att_armyCount + v.army
            att_armyAfterCount = att_armyAfterCount + v.army
        else
            -- def_armyAfterCount = def_armyAfterCount + v.armyAfter
            def_armyCount = def_armyCount + v.army
            def_armyAfterCount = def_armyAfterCount + v.army
        end
    end


    local panel_main_left = tolua.cast(panel_left:getChildByName("Panel_810357"),"Layout")
	local light_left = tolua.cast(panel_main_left:getChildByName("ImageView_810129"),"ImageView")
	

	local panel_main_right = tolua.cast(panel_right:getChildByName("Panel_810358"),"Layout")
	local light_right = tolua.cast(panel_main_right:getChildByName("ImageView_810129_0"),"ImageView")

    armyCountData = {att_armyCount = att_armyCount, att_armyAfterCount = att_armyAfterCount, def_armyCount = def_armyCount, 
    				def_armyAfterCount = def_armyAfterCount, light_left =light_left:getPositionX(),
    			 	light_right = light_right:getPositionX(),
    			 	}

    setArmyCountUI( )

	local battle_id = BattlaAnimationData.getBattleId()
	heroData = {}
	formationIndex = {}
	local heroIndex = {}
	local heroIndex1 = {}

	local player_name = nil
	local enemy_name = nil

	local player_union_name = nil
	local enemy_union_name = nil
	local battleReport = reportData.getReport(battle_id)
	if not reportData.returnAttackOrDefend(battleReport ) then
		heroIndex = {5,6,7}
		heroIndex1 = {4,3,2}

		if battleReport.npc == 0 then
			player_name = battleReport.defend_name
		else
			player_name = languagePack["shoujun"]
		end
		enemy_name = battleReport.attack_name

		if string.len(battleReport.defend_union_name) > 0 then
            player_union_name = battleReport.defend_union_name
        end

        if string.len(battleReport.attack_union_name) > 0 then
            enemy_union_name = battleReport.attack_union_name
        end

		-- player_union_name = 
	else
		heroIndex = {4,3,2}
		heroIndex1 = {5,6,7}
		player_name = battleReport.attack_name

		if battleReport.npc == 0 then
			enemy_name = battleReport.defend_name
		else
			enemy_name = languagePack["shoujun"]
		end

		if string.len(battleReport.attack_union_name) > 0 then
            player_union_name = battleReport.attack_union_name
        end

        if string.len(battleReport.defend_union_name) > 0 then
            enemy_union_name = battleReport.defend_union_name
        end
	end

    -- 我方名字
    local attName = tolua.cast(panel_left:getChildByName("name_left"),"Label")
    attName:setText(player_name)
    -- 我方同盟
    local union_panel = tolua.cast(panel_left:getChildByName("temp_image_union_left"),"Label")
    local attUnionName = tolua.cast(union_panel:getChildByName("union_name_left"),"Label")
    if player_union_name then
    	attUnionName:setText(player_union_name)
    else
    	union_panel:setVisible(false)
    end

    -- 敌方名字
    local defName = tolua.cast(panel_right:getChildByName("name_right"),"Label")
    defName:setText(enemy_name)
    -- 敌方同盟
    local union_panel_right = tolua.cast(panel_right:getChildByName("temp_image_union_right"),"Label")
    local defUnionName = tolua.cast(union_panel_right:getChildByName("union_right"),"Label")
    if enemy_union_name then
    	defUnionName:setText(enemy_union_name)
    else
    	union_panel_right:setVisible(false)
    end

	local count = 0
	for i, v in ipairs( heroIndex) do
		if tmp_armyinfo[v] and tmp_armyinfo[v].level > 0 then
			count = count + 1
			formationIndex[v] = count--formation[count]
			formationHeroToPos[count] = v
		end
	end

	count = 3
	for i, v in ipairs( heroIndex1) do
		if tmp_armyinfo[v] and tmp_armyinfo[v].level > 0 then
			count = count + 1
			formationIndex[v] = count--formation[count]
			formationHeroToPos[count] = v
		end
	end

	local armyCount = nil
	local cfg_hero_data = nil
	local singel_data = nil
	local isSelf = nil
	local id = nil
	local tempid = nil
	local zhengorfu = 1
	local pos = nil
	local realPos = nil
	local hit_range = nil
	local name = nil--{"bulegong_0","redgong_0","buleqiang_0","redqiang_0", "buleqiqiang_0", "redqiqiang_0"}
	for i,v in pairs(formationIndex) do
		pos = i--math.floor(i/10)
		realPos = v
		-- local index_temp = 
		if realPos <=3 then
			-- tempid = name[Tb_cfg_hero[tmp_armyinfo[pos].heroid].hero_type*2-1]
			
			zhengorfu = 1
		else
			-- tempid = name[Tb_cfg_hero[tmp_armyinfo[pos].heroid].hero_type*2]
			
			zhengorfu = -1
		end

		armyCount = realCount( tmp_armyinfo[pos].army )
		for m = 1, armyCount do
			cfg_hero_data = Tb_cfg_hero[tmp_armyinfo[pos].heroid]
			hit_range = cfg_hero_data.hit_range
			-- 弓
			if cfg_hero_data.hero_type == 1 then
				-- 这个是为了防止配表错误,弓兵的攻击范围不可能是1
				if hit_range == 1 then
					hit_range = 2 
				end
			end

			singel_data = battleFormation[cfg_hero_data.hero_type*10+hit_range][m]
			local coorx, coory = formation[v][1] + zhengorfu*1*singel_data[1], formation[v][2]+zhengorfu*1*singel_data[2]
			local x, y = getMapSpritePos(0,0, midX,midY, coorx,coory, _width, _height  )

			if not reportData.returnAttackOrDefend(reportData.getReport(battle_id) ) then
				if pos >= 5  then
					isSelf = true
				else
					isSelf = false
				end
			else
				if pos <= 4  then
					isSelf = true
				else
					isSelf = false
				end
			end

			if m ~= 1 then
				table.insert(armyLeaderInfo[pos*100+1].underIndex, pos*100+m)
			end

			armyInfo[pos*100+m] = { dead = false, armyType = cfg_hero_data.hero_type,
									wid = coorx*10000+coory, lastWid =coorx*10000+coory , isSelf = isSelf,
									attackArea = battleArmyConfig[cfg_hero_data.hero_type].attackArea, position = pos, aiType = 5,
									targetIndex = nil, targetWid = nil, armyleader = pos*100+1, object = nil, 
									heroid = tmp_armyinfo[pos].heroid, 
									speed = battleArmyConfig[cfg_hero_data.hero_type].speed, 
									collisionArea = battleArmyConfig[cfg_hero_data.hero_type].collisionArea, 
									beAttacked = false, attackTarget = nil, uniqueId = pos*100+m, iswait = true,
									direction = 1, action = "walk", isOb = "", lastDirection = nil, animationName = nil,
									arrowPlay = false, a =nil, b=nil, c=nil, beginX = nil, endX = nil}

			if isSelf then
				armyInfo[pos*100+m].isOb = "player"
			else
				armyInfo[pos*100+m].isOb = "enemy"
				armyInfo[pos*100+m].direction = 2
			end

			if m == 1 then
				armyInfo[pos*100+m].action = "leader"
				if pos == 2 or pos == 7 then
					armyInfo[pos*100+m].action = "base"
				end
			end

			if m ~= 1 then
				name = armyInfo[pos*100+m].isOb.."_"..armyInfo[pos*100+m].armyType.."_".. armyInfo[pos*100+m].direction.."_" .."wait".."_1"..".png"
				armyInfo[pos*100+m].animationName = armyInfo[pos*100+m].isOb.."_"..armyInfo[pos*100+m].armyType.."_".. armyInfo[pos*100+m].direction.."_" .."wait"
			else
				name = armyInfo[pos*100+m].isOb.."_" ..armyInfo[pos*100+m].action.."_"..armyInfo[pos*100+m].direction.."_wait".."_1"..".png"
				armyInfo[pos*100+m].animationName = armyInfo[pos*100+m].isOb.."_" ..armyInfo[pos*100+m].action.."_"..armyInfo[pos*100+m].direction.."_wait"
			end
			local sprite = cc.Sprite:createWithSpriteFrameName(name)
			battleBatchNode:addChild(sprite)
			-- armyRootLayer:addChild(sprite)

			if armyInfo[pos*100+m].armyType == 3 or m == 1 then
				sprite:setAnchorPoint(cc.p(0.5,0.3))
			else
				sprite:setAnchorPoint(cc.p(0.5,10/sprite:getContentSize().height))
			end

			local worldx, worldy,realx, realy = getMapRealPos( x, y )
			sprite:setPosition(cc.p(realx, realy))
			sprite:setScale(config.scaleIn3D( worldx,worldy,angel, _width, _height ))
			battleBatchNode:reorderChild(sprite, coorx*10000-coory)
			-- armyRootLayer:reorderChild(sprite, coorx*10000-coory)

			armyInfo[pos*100+m].object = sprite
			if m == 1 then
				--跟随sprite移动，用于放特效和头像
				local spriteLayer = cc.LayerColor:create(cc.c4b(0,0,0,0), 1, 1)
				iconLayer:addChild(spriteLayer)

				spriteLayer:setAnchorPoint(cc.p(0.5,0.5))
				spriteLayer:setPosition(iconLayer:convertToNodeSpace(cc.p(worldx, worldy+ m_scale*sprite:getScale()*sprite:getContentSize().height*0.8)))


				local spriteNode = cc.LayerColor:create(cc.c4b(0,0,0,0), 1, 1)
				iconLayer:addChild(spriteNode)

				spriteNode:setAnchorPoint(cc.p(0.5,0.5))
				spriteNode:setPosition(iconLayer:convertToNodeSpace(cc.p(worldx, worldy)))

				armyLeaderInfo[pos*100+m] = {dead = false, --[[judgeFist = false,]] armyType = cfg_hero_data.hero_type, activity = true, 
											wid = coorx*10000+coory, isSelf = isSelf, lastWid =coorx*10000+coory , heroid = tmp_armyinfo[pos].heroid,
											attackArea = battleArmyConfig[cfg_hero_data.hero_type].attackArea,
											position = pos, speed = battleArmyConfig[cfg_hero_data.hero_type].speed, 
											collisionArea = battleArmyConfig[cfg_hero_data.hero_type].collisionArea, underIndex = {},
											targetIndex = nil, effectiveCount = 0, lastEffectiveCount = 0, aiType = 5, deadCount = 0,
											left_count = tmp_armyinfo[pos].army, hit_range = hit_range,
											totalCount =armyCount, realTotalCount = tmp_armyinfo[pos].army,
											isWar = nil, isDying = nil}


				
				heroData[pos] = {target = spriteLayer, isSelf = isSelf, icontargetX = spriteLayer:getPositionX(), node = spriteNode,
						icontargetY = spriteLayer:getPositionY(), level = tmp_armyinfo[pos].level, heroid = tmp_armyinfo[pos].heroid}

				local card_small = initSmallIcon(pos*100+m)
				card_small:setAnchorPoint(cc.p(0.5,0))
				spriteLayer:addChild(card_small)
						
				local card_mid,card = initMidIcon(pos*100+m)
				card_mid:setAnchorPoint(cc.p(0.5,0))
				spriteLayer:addChild(card_mid)

				heroData[pos].small_icon =card_small
				heroData[pos].mid_icon = card_mid
				heroData[pos].card = card

				setIconArmyCount(pos)
			end

			armyInfo[pos*100+m].object:setZOrder(coorx*10000- coory)

			-- local label = CCLabelTTF:create(pos*100+m,config.getFontName(), 20, CCSize(600, 50), kCCTextAlignmentCenter)
			-- local label = cc.LayerColor:create(cc.c4b(0,0,0,255), 5, 5)
			-- armyRootLayer:addChild(label)
			-- label:setPosition(cc.p(x,y))
			-- armyInfo[pos*100+m].label = label

			setGridToFull(coorx, coory, pos*100+m)
			playAnimationSequence(pos*100+m, armyInfo[pos*100+m].animationName )
		end
	end
	-- addFirstGuideLine()
	-- addSecondGuideLine()
	playAnimationByTable()
	setEffectCount()
end

function skillChangeEffectCount(pos, range )
	if armyLeaderInfo[pos*100+1] then
		armyLeaderInfo[pos*100+1].hit_range = armyLeaderInfo[pos*100+1].hit_range + range
		setEffectCount()
	end
end

--设置有效目标数
function setEffectCount( )
	local pos = nil
	local effectCount = 0
	local effectiveTarget = {}
	for i ,v in pairs(armyLeaderInfo) do
		pos = math.floor(i/100)
		effectCount, effectiveTarget = effectiveTargetCount(pos )
		if effectCount == 0 then
			v.activity = false
		else
			v.activity = true
		end

		v.effectiveTarget = effectiveTarget
		v.lastEffectiveCount = v.effectiveCount
		v.effectiveCount = effectCount

		-- if v.lastEffectiveCount ~= v.effectCount then
			-- if v.aiType < 5 then
		v.aiType = battleAI[v.position*100+v.armyType*10+v.effectiveCount]
		for m , n in ipairs(v.underIndex) do
			armyInfo[n].aiType = v.aiType
		end
			-- end
		-- end
	end
end

-- 设置ui上面的总兵力
function setArmyCountUI( )
	local temp_widget = mLayer:getWidgetByTag(999)
	local panel_left = tolua.cast(temp_widget:getChildByName("Panel_left"),"Layout")
	local panel_right = tolua.cast(temp_widget:getChildByName("Panel_right"),"Layout")
	-- 总兵力
	-- 我方
	local total_army_left = tolua.cast(panel_left:getChildByName("army_total_count_left"),"Label")
	total_army_left:setText("/".. armyCountData.att_armyCount)

	local army_left_1 = tolua.cast(panel_left:getChildByName("army_left_1"),"Label")
	army_left_1:setText(armyCountData.att_armyAfterCount)
	army_left_1:setPositionX(total_army_left:getPositionX()-total_army_left:getSize().width)

	local panel_main_left = tolua.cast(panel_left:getChildByName("Panel_810357"),"Layout")
	-- 我进度条
	local attackPro = tolua.cast(panel_main_left:getChildByName("LoadingBar_810332"),"LoadingBar")
	local percent = armyCountData.att_armyAfterCount/armyCountData.att_armyCount
	attackPro:setPercent(100*percent)

	-- 光柱要跟随进度条移动
	local light_left = tolua.cast(panel_main_left:getChildByName("ImageView_810129"),"ImageView")
	light_left:setPositionX( armyCountData.light_left + attackPro:getSize().width*(1-percent))


	-- 敌方
	local left_army_2 = tolua.cast(panel_right:getChildByName("left_army_2"),"Label")
	left_army_2:setText(armyCountData.def_armyAfterCount)

	local total_army_right = tolua.cast(panel_right:getChildByName("army_total_right"),"Label")
	total_army_right:setText("/"..armyCountData.def_armyCount)
	total_army_right:setPositionX(left_army_2:getPositionX()+left_army_2:getSize().width)

	local panel_main_right = tolua.cast(panel_right:getChildByName("Panel_810358"),"Layout")
	-- 敌方进度条
	percent = armyCountData.def_armyAfterCount/armyCountData.def_armyCount
	local defkPro = tolua.cast(panel_main_right:getChildByName("LoadingBar_810333"),"LoadingBar")
	defkPro:setPercent(100*percent)

	-- 光柱要跟随进度条移动
	local light_right = tolua.cast(panel_main_right:getChildByName("ImageView_810129_0"),"ImageView")
	light_right:setPositionX( armyCountData.light_right - defkPro:getSize().width*(1-percent))
	
end

function setArmyCount(heroPos, num )
	local leader =armyLeaderInfo[heroPos*100+1]
	local count = 0
	if leader and num ~= 0 then
		if heroPos <= 4 then
			armyCountData.att_armyAfterCount = armyCountData.att_armyAfterCount + num
		else
			armyCountData.def_armyAfterCount = armyCountData.def_armyAfterCount + num
		end
		setArmyCountUI()
		leader.left_count = leader.left_count + num
		setIconArmyCount(heroPos)
		if num > 0 then
		else
			local realNum = math.floor(leader.totalCount*math.abs(num)/leader.realTotalCount)
			leader.deadCount = leader.deadCount + realNum
			for i , v in pairs(leader.underIndex) do
				if armyInfo[v] and not armyInfo[v].dead and armyInfo[v].beAttacked then
					setDieActionType(v )
					count = count + 1
					if count >= realNum then
						break
					end
				end
			end
		end
	end
end

function setHeroDie( heroPos )
	local leader =armyLeaderInfo[heroPos*100+1]
	local left_count = 0
	for i ,v in ipairs(leader.underIndex) do
		if not armyInfo[v].dead then
			left_count = left_count + 1
		end
	end
	leader.deadCount = left_count
	leader.isDying = true
	for i , v in pairs(leader.underIndex) do
		if armyInfo[v] and not armyInfo[v].dead and armyInfo[v].beAttacked then
			setDieActionType(v )
		end
	end


	-- if leader then
		-- armyLeaderInfo[heroPos*100+1].dead = true
		-- armyInfo[heroPos*100+1].dead = true
		-- armyInfo[heroPos*100+1].object:setVisible(false)

		-- heroData[armyLeaderInfo[heroPos*100+1].position].target:setVisible(false)
		-- for i , v in ipairs(leader.underIndex) do
		-- 	if armyInfo[v] and not armyInfo[v].dead then
		-- 		armyInfo[v].dead = true
		-- 		if gridToArmyData[armyInfo[v].wid] and gridToArmyData[armyInfo[v].wid] == v then
		-- 			gridToArmyData[armyInfo[v].wid] = nil
		-- 		end
		-- 		armyInfo[v].action = "die"
		-- 	end
		-- end
	-- end
	-- setEffectCount()
end

local function setGridToNil(index )
	if gridToArmyData[armyInfo[index].wid] and gridToArmyData[armyInfo[index].wid] == index then
		local tmx, tmy = math.floor(armyInfo[index].wid/10000), armyInfo[index].wid%10000
		if gridToArmyData[armyInfo[index].wid] and gridToArmyData[armyInfo[index].wid] == index then
			-- for k=tmx- armyInfo[index].collisionArea, tmx+ armyInfo[index].collisionArea do
				-- for q=tmy- armyInfo[index].collisionArea, tmy+ armyInfo[index].collisionArea do
					gridToArmyData[tmx*10000+ tmy] = nil
			-- 	end
			-- end
		end
	end
end

function setGridToFull(coorx,coory,index)
	-- for k=coorx- armyInfo[index].collisionArea, coorx+ armyInfo[index].collisionArea do
	-- 	for q=coory- armyInfo[index].collisionArea, coory+ armyInfo[index].collisionArea do
			gridToArmyData[coorx*10000+ coory] = index
	-- 	end
	-- end
end

local function getSpeed(index )
	if armyInfo[index].armyType == 1 then
		return 50*m_speed
	elseif armyInfo[index].armyType == 2 then
		return 50*m_speed
	else
		return 100*m_speed
	end
end

local function setArrowPos( index, count_index)
	if arrowHandler[count_index].beginX then
		local dt = arrowHandler[count_index].beginX
		local y = arrowHandler[count_index].a*dt*dt+arrowHandler[count_index].b*dt+arrowHandler[count_index].c
		arrowHandler[count_index].arrow:setPosition(cc.p(dt, y))
		local tan = math.deg(math.atan(2*arrowHandler[count_index].a*dt+arrowHandler[count_index].b))
		tan = 90-tan
		arrowHandler[count_index].arrow:setRotation(tan)

		if arrowHandler[count_index].beginX >= arrowHandler[count_index].endX then
			if dt - arrowHandler[count_index].arrowDt < arrowHandler[count_index].endX then
				-- armyInfo[index].arrowOne = false
				-- armyInfo[index].a = nil
				-- armyInfo[index].b = nil
				-- armyInfo[index].c = nil
				-- armyInfo[index].beginX = nil
				-- armyInfo[index].endX = nil
				-- armyInfo[index].arrow:setVisible(false)
				arrowHandler[count_index].arrow:removeFromParentAndCleanup(true)
				if arrowHandler[count_index].timer then
					scheduler.remove(arrowHandler[count_index].timer)
					arrowHandler[count_index] = nil
				end
			else
				arrowHandler[count_index].beginX = dt - arrowHandler[count_index].arrowDt
			end
		else
			if dt + arrowHandler[count_index].arrowDt > arrowHandler[count_index].endX then
				-- armyInfo[index].arrowOne = false
				-- armyInfo[index].a = nil
				-- armyInfo[index].b = nil
				-- armyInfo[index].c = nil
				-- armyInfo[index].beginX = nil
				-- armyInfo[index].endX = nil
				-- armyInfo[index].arrow:setVisible(false)
				arrowHandler[count_index].arrow:removeFromParentAndCleanup(true)
				if arrowHandler[count_index] then
					scheduler.remove(arrowHandler[count_index].timer)
					arrowHandler[count_index] = nil
				end
			else
				arrowHandler[count_index].beginX = dt + arrowHandler[count_index].arrowDt
			end
		end

	end
end

-- 1 左下方向 2 右上方向 3 左上方向 4 右下方向
local function setDirection(index, coorx, coory )
	local playerX, playerY = math.floor(armyInfo[index].wid/10000), armyInfo[index].wid%10000
	local targetX, targetY = coorx, coory--math.floor(armyInfo[pos].wid/10000), armyInfo[pos].wid%10000
	if armyInfo[index].targetIndex and not armyInfo[armyInfo[index].targetIndex].dead then
		local enemy = armyInfo[armyInfo[index].targetIndex]
		local enemy_x = enemy.object:getPositionX()
		local player_x= armyInfo[index].object:getPositionX()

		if enemy_x >= player_x then
			armyInfo[index].direction = 1
		else
			armyInfo[index].direction = 2
		end
		return 
	end	

	if targetY >= playerY then
		armyInfo[index].direction = 1
	else
		armyInfo[index].direction = 2
	end
end

-- 弓兵播放战斗的动画
function setAttackAction(index,pos )
	if isStop then return end
	if armyInfo[index].armyType == 1 then
		-- if armyInfo[index].arrowPlay or armyInfo[index].arrowOne then return end
		local x2, y2 =armyInfo[pos].object:getPositionX(), armyInfo[pos].object:getPositionY() --getMapSpritePos(0,0, midX,midY, math.floor(targetWid/10000),targetWid%10000, _width, _height  )
		y2 = y2+armyInfo[pos].object:getContentSize().height/2
		local x1,y1 = armyInfo[index].object:getPositionX(), armyInfo[index].object:getPositionY()+armyInfo[index].object:getContentSize().height/2 --getMapSpritePos(0,0, midX,midY, math.floor(armyInfo[index].wid/10000),armyInfo[index].wid%10000, _width, _height  )
		local x3, y3 = x1+(x2-x1)/2, 10+math.max(y2,y1)

		local a = ((x1-x3)*(y1-y2)-(x1-x2)*(y1-y3))/((x1*x1-x2*x2)*(x1-x3) - (x1*x1-x3*x3)*(x1-x2))
		local b = (y1-y2-a*(x1*x1- x2*x2))/(x1-x2)
		local c = y1-a*x1*x1-b*x1

		local label = nil--armyInfo[index].arrow
		if not label then
			label = cc.LayerColor:create(cc.c4b(0,0,0,255), 2, 10)
			armyRootLayer:addChild(label)
			label:ignoreAnchorPointForPosition(false)
			label:setAnchorPoint(cc.p(0.5,0.5))
			-- armyInfo[index].arrow = label
		end
		-- label:setVisible(true)
		label:setPosition(cc.p(x1, y1))
		-- armyInfo[index].arrowPlay = true
		-- armyInfo[index].arrowOne = true

		local count_index = 0
		for i=1, 10000 do
			if not arrowHandler[index*10000+i] then
				count_index = index*10000+i
				arrowHandler[count_index] = {}
				break
			end
		end


		arrowHandler[count_index].a = a
		arrowHandler[count_index].b = b
		arrowHandler[count_index].c = c
		arrowHandler[count_index].beginX = x1
		arrowHandler[count_index].endX = x2
		arrowHandler[count_index].arrowDt = 10*m_speed
		arrowHandler[count_index].arrow = label
		
		arrowHandler[count_index].timer = scheduler.create(function (  )
			setArrowPos(index, count_index)
		end,0)

		-- armyInfo[index].object:runAction(animation.sequence({cc.DelayTime:create(2),cc.CallFunc:create(function ( )
		-- 	armyInfo[index].arrowPlay = false
		-- end) }))
		
	end
end

-- 设置是否被攻击，便于优先播放死亡动作
local function setAttackTarget(index,pos )
	if pos then
		armyInfo[pos].beAttacked = index
		armyInfo[index].attackTarget = pos
		local heropos = math.floor(pos/100)*100+1
		if armyLeaderInfo[heropos].deadCount > 0 then
			setDieActionType(pos )
		end
	else
		if armyInfo[index].attackTarget then
			if armyInfo[armyInfo[index].attackTarget].beAttacked and armyInfo[armyInfo[index].attackTarget].beAttacked == index then
				armyInfo[armyInfo[index].attackTarget].beAttacked = false
			end
		end
		armyInfo[index].attackTarget = nil
	end
end

-- 播放结束的动画
function playEndAnimation(  )
	if m_endAnimationName and frameRootLayer and not BattleResultSum.getInstance() then
		for i, v in pairs(armyLeaderInfo) do
			if v.isDying then
				heroData[v.position].target:setVisible(false)
			end
		end

		local armature = CCArmature:create(m_endAnimationName)
		armature:getAnimation():playWithIndex(0)
		armature:getAnimation():setSpeedScale(armature:getAnimation():getSpeedScale()*m_speed)
		frameRootLayer:getParent():addChild(armature)
		local point = frameRootLayer:getParent():convertToWorldSpace(cc.p(config.getWinSize().width*0.5,config.getWinSize().height*0.5))
		armature:setPosition(point)
		armature:getAnimation():setMovementEventCallFunc(function (armatureNode, eventType, name )
			if eventType == 1 then
				armature:removeFromParentAndCleanup(true)
				BattleAnimationController.stopAi()
				BattleAnimationController.openBattleResult( )
			end
		end)
		armature:setScale(2*m_scale)
		if animationToMusic[m_endAnimationName] then
			LSound.playSound(animationToMusic[m_endAnimationName])
		end
	end
end

function setDieActionType(index )
	local pos = math.floor(index/100)*100+1

	-- 为了保证战斗肯定能结束，规定了总兵力的40%是不死的，只有当主将已经被判断为死亡的时候，这些兵才会判断死亡
	local undead_count = math.floor(0.4*#armyLeaderInfo[armyInfo[index].armyleader].underIndex)
	if index%100 <= undead_count then
		if not armyLeaderInfo[pos].isDying then
			return 
		end
	end

	armyLeaderInfo[pos].deadCount = armyLeaderInfo[pos].deadCount - 1
	armyInfo[index].dead = true
	armyInfo[index].action = "die"
	if gridToArmyData[armyInfo[index].wid] and gridToArmyData[armyInfo[index].wid] == index then
		gridToArmyData[armyInfo[index].wid] = nil
	end
	setAttackTarget(index,false )

	for i ,v in ipairs(armyLeaderInfo[pos].underIndex) do
		if not armyInfo[v].dead then
			return
		end
	end

	armyLeaderInfo[pos].dead = true
	armyInfo[pos].dead = true
	armyInfo[pos].object:setVisible(false)
	heroData[armyLeaderInfo[pos].position].target:setVisible(false)

	setEffectCount()

	for i, v in pairs(armyLeaderInfo) do
		if v.dead then
			if v.deadCount > 0 then
				return
			end
		end
	end

	if m_isEndAnalisy then
		playEndAnimation(  )
	end
end

local function setActionType(index,str )
	armyInfo[index].lastAction = armyInfo[index].action
	armyInfo[index].action = str
	if str == "attack" then
		-- local pos = math.floor(index/100)*100+1
		-- if armyLeaderInfo[pos].deadCount > 0 then
		-- 	setDieActionType(index )
		-- end
	end
end

function setFrameCall(frame, callback,coorx,coory,index )
	if not m_frame_callFunc[m_frame_index+frame] then
		m_frame_callFunc[m_frame_index+frame] = {}
	end

	table.insert(m_frame_callFunc[m_frame_index+frame], {callFunc =callback, coorx = coorx, coory=coory, index = index })
end

function reorderNode(index, coorx, coory )
	battleBatchNode:reorderChild(armyInfo[index].object, coorx*10000- coory)
end

local function isHasArea( pos, x, y )
	local effect_width = heroData[pos].small_icon:getSize().width*0.5
	local effect_height = heroData[pos].small_icon:getSize().height*0.5
	for i ,v in pairs(heroData) do
		if i~= pos and not armyInfo[pos*100+1].dead and math.abs(v.icontargetX - x) < effect_width and
			math.abs(v.icontargetY - y) < effect_height then
			-- if not heightest or (heightest and heightest < v.target:getPositionY()) then
			-- 	heightest = v.target:getPositionY()
			-- end
			return false
		end
	end
	return true
end

-- 头像实际位置
local function getIconRealHeight(pos, x, y )
	local heightest = nil
	local widthest = nil
	local effect_width = heroData[pos].small_icon:getSize().width*0.5
	local effect_height = heroData[pos].small_icon:getSize().height*0.5
	local tempx, tempy = x, y

	local flag = false

	-- 下一个位置是否有位置
	if not flag and isHasArea( pos, x, y ) then
		flag = true
	end

	-- 下一个位置的左边是否有位置
	if not flag and isHasArea(pos, x+effect_width, y ) then
		tempx = x+effect_width
		tempy = y
		flag=  true
	end

	-- 下一个位置右边是否有位置
	if not flag and isHasArea(pos, x-effect_width, y ) then
		tempx = x-effect_width
		tempy = y
		flag=  true
	end 
	
	-- 下一个位置的上边是否有位置
	while not flag do
		tempy = tempy + effect_height
		if isHasArea(pos, x, tempy ) then
			flag=  true
		end
	end

	-- 检查是否超过了屏幕上限
	local point = iconLayer:convertToWorldSpace(cc.p(tempx,tempy))
	if point.y+heroData[pos].small_icon:getSize().height > forbidAreaHeight then
		for i=1, 10 do
			if isHasArea(pos, tempx- i*effect_width, forbidAreaHeight - heroData[pos].small_icon:getSize().height ) then
				tempx,tempy = tempx- i*effect_width, forbidAreaHeight - heroData[pos].small_icon:getSize().height
				break
			end

			if isHasArea(pos, tempx+ i*effect_width, forbidAreaHeight - heroData[pos].small_icon:getSize().height ) then
				tempx,tempy = tempx+ i*effect_width, forbidAreaHeight - heroData[pos].small_icon:getSize().height
				break
			end
		end
	end

	-- 设置下一个位置
	heroData[pos].icontargetX = tempx
	heroData[pos].icontargetY = tempy
	return tempx,tempy

		
end
-- B1	变阵	部队进行阵型变化		用于表示战前buff和一些效果的展示
-- B2	阵地作战	保持阵型等待		
-- B3	散开	小兵间的最小间距不小于XXX，并缓慢向前移动		
-- B4	冲锋	部队朝目标地点移动，目标是地点而不是对方士兵		
-- B5	索敌进攻	寻找最接近的部队（目标的领头），向其接近		
-- B6	自由作战	跟随主将寻找一个部队的士兵进行战斗		
-- 拿旗的骑兵的ai，优先搜索前面有目标时停下来
-- aitype 1 前进 2坐标 3主将 4 最近目标 99 没有目标
local function leaderAction(index )
	if not armyLeaderInfo[index].dead and not isStop then
		local coorx, coory,pos, isNextWar = armyWithFlagAI(index,{aiType =differentAI(index), wid =nil } )
		if coorx and coory and (not gridToArmyData[coorx*10000 + coory] or gridToArmyData[coorx*10000 + coory] ==index) then
			local x, y =getMapSpritePos(0,0, midX,midY, coorx,coory, _width, _height  )
			if getRightCoord( x, y, coorx, coory ) then
				setGridToNil(index )

				setDirection(index, coorx, coory)
				armyInfo[index].lastWid = armyInfo[index].wid
				armyInfo[index].wid = coorx*10000+coory
				armyLeaderInfo[index].wid = coorx*10000+coory

				if armyInfo[index].wid ~= armyInfo[index].lastWid then
					if isNextWar then
						x = x+ math.random(-15, 15)
						y = y+math.random(-5,5)
					end
				end
				local worldx, worldy,realx, realy = getMapRealPos( x, y )

				local dis = ccpDistance(cc.p(realx,realy), ccp(armyInfo[index].object:getPositionX(),armyInfo[index].object:getPositionY()))
				local time = dis/getSpeed(index)
				if time == 0 then
					time = 1
				end
				local action = animation.sequence({CCMoveTo:create(time, ccp(realx,realy)), cc.CallFunc:create(function ( )
					battleBatchNode:reorderChild(armyInfo[index].object, coorx*10000- coory)
					armyInfo[index].object:setScale(config.scaleIn3D( worldx,worldy,angel, _width, _height ))
					leaderAction(index )
				end)})
				armyInfo[index].object:runAction(action)
				heroData[armyInfo[index].position].node:runAction(CCMoveTo:create(time, heroData[armyInfo[index].position].node:getParent():convertToNodeSpace(cc.p(worldx, worldy))))

				local point = iconLayer:convertToNodeSpace(cc.p(worldx, worldy+ m_scale*armyInfo[index].object:getScale()*armyInfo[index].object:getContentSize().height*0.8))
				local rx, ry = getIconRealHeight(armyInfo[index].position, point.x, point.y )
				if isNextWar then
					heroData[armyInfo[index].position].target:runAction(CCMoveTo:create(time,ccp(rx, ry) ))
				else
					if armyInfo[index].wid ~= armyInfo[index].lastWid then
						heroData[armyInfo[index].position].target:runAction(CCMoveTo:create(time,point ))
					else
						heroData[armyInfo[index].position].target:runAction(CCMoveTo:create(0.9,ccp(rx, ry) ))
					end
				end

				setGridToFull(coorx,coory,index)
			else
				local action = animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
					leaderAction(index )
				end)})
				armyInfo[index].object:runAction(action)
			end
		else
			local action = animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
				leaderAction(index )
			end)})
			armyInfo[index].object:runAction(action)
		end
	end
end

function armyAction(index )
	if not armyInfo[index].dead and not isStop then
		local coorx, coory,pos,isNextWar = armyNormalAI(index,{aiType = armyInfo[index].aiType})
		if coorx and coory and (not gridToArmyData[coorx*10000 + coory] or gridToArmyData[coorx*10000 + coory] ==index) then
			
			local x, y =getMapSpritePos(0,0, midX,midY, coorx,coory, _width, _height  )

			if getRightCoord( x, y, coorx, coory ) then
				setGridToNil(index)
				local action = nil
				local frame = nil
				if coorx*10000+coory ~= armyInfo[index].wid then
					if isNextWar then
						x = x+ math.random(-15, 15)
						y = y+ math.random(-5,5)
					end
					local worldx, worldy,realx, realy = getMapRealPos( x, y )
					local dis = ccpDistance(cc.p(realx, realy), ccp(armyInfo[index].object:getPositionX(),armyInfo[index].object:getPositionY()))
					action = animation.sequence({CCMoveTo:create(dis/getSpeed(index), ccp(realx, realy)), cc.CallFunc:create(function ( )
						battleBatchNode:reorderChild(armyInfo[index].object, coorx*10000- coory)
						armyInfo[index].object:setScale(config.scaleIn3D( worldx, worldy,angel, _width, _height ))
						armyAction(index )
					end)})
				else
					action = animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
						armyAction(index )
					end)})
				end

				setDirection(index, coorx,coory)

				armyInfo[index].object:runAction(action)

				armyInfo[index].lastWid = armyInfo[index].wid
				armyInfo[index].wid = coorx*10000+coory
				setGridToFull(coorx, coory, index)
				if pos then
					armyInfo[index].isWar = true
					setActionType(index,"attack" )
				else
					setActionType(index,"walk" )
					armyInfo[index].isWar = false
				end
				setAttackTarget(index,pos )
			else
				local action = animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
					armyAction(index )
				end)})
				armyInfo[index].object:runAction(action)
				armyInfo[index].isWar = false
				setActionType(index,"walk" )
				setAttackTarget(index,false )
			end
		else
			local action = animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
				armyAction(index )
			end)})
			setActionType(index,"walk" )
			armyInfo[index].object:runAction(action)
			armyInfo[index].isWar = false
			setAttackTarget(index,false )
		end
	end
end

function stopAi( )
	isStop = true
	-- isPause = true
	for i, v in pairs(armyLeaderInfo) do
		armyInfo[i].iswait = true
		for m, n in ipairs(v.underIndex) do
			setActionType(n, "walk")
			armyInfo[n].iswait = true
		end
	end
end

function beginAi( )
	if BattleResultSum.getInstance() then return end
	isStop = false
	for i, v in pairs(armyLeaderInfo) do
		leaderAction(i )
	end

	for i, v in pairs(armyLeaderInfo) do
		armyInfo[i].iswait = false
		for m, n in ipairs(v.underIndex) do
			armyAction(n)
			armyInfo[n].iswait = false
		end
	end
end

function getIsAttack( )
	for i,v in pairs(armyLeaderInfo) do
		for m, n in ipairs(v.underIndex) do
			if armyInfo[n].isWar then
				return true
			end
		end
	end
	return false
end

-- 是否直接打开动画战报  是否战斗结束不要弹出结算界面 , loading界面完了是否有回调
function create(isDirect, isNoResult, playeCallFunc)
	require("game/battle/battleResultSum")
	if mLayer then return end
	m_openDir = isDirect
	m_isNoResult = isNoResult
	
	math.randomseed(BattlaAnimationData.getBattleId())

	-- config.loadAnimationFile()
	-- for i,v in pairs(BattleAnimation.getAnimationName()) do
	-- 	if i~= "tongyong" then
	-- 		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/battle/"..i..".ExportJson")
	-- 	end
	-- end

	BattleLoadingUI.create(playeCallFunc)
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/battle/battle_dir_1_2.plist")

	-- mLayer = TouchGroup:create()

	-- uiManager.add_panel_to_layer(mLayer, uiIndexDefine.BATTLA_ANIMATION_UI)
	-- uiManager.showConfigEffect(uiIndexDefine.BATTLA_ANIMATION_UI,mLayer,nil,999,{mLayer})

	-- 0.6*config.getgScale()
	-- 战斗背景层
	-- local back =cc.Sprite:create("test/res_single/battle_background.png")
	-- armyRootLayerxx = Layout:create()
	-- armyRootLayerxx:ignoreAnchorPointForPosition(false)
	-- armyRootLayerxx:setAnchorPoint(cc.p(0.5,0.5))
	-- armyRootLayerxx:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	-- armyRootLayerxx:setScale(config.getWinSize().height/back:getContentSize().height)
	-- mLayer:addWidget(armyRootLayerxx)
	-- armyRootLayerxx:addChild(back)

	-- init()
end

function battleAsyncCreate( )
	mLayer = TouchGroup:create()

	uiManager.add_panel_to_layer(mLayer, uiIndexDefine.BATTLA_ANIMATION_UI)
	uiManager.showConfigEffect(uiIndexDefine.BATTLA_ANIMATION_UI,mLayer,nil,999,{mLayer})

	-- 0.6*config.getgScale()
	-- 战斗背景层
	local back =cc.Sprite:create("test/res_single/battle_background.png")
	armyRootLayerxx = Layout:create()
	armyRootLayerxx:ignoreAnchorPointForPosition(false)
	armyRootLayerxx:setAnchorPoint(cc.p(0.5,0.5))
	armyRootLayerxx:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	armyRootLayerxx:setScale(config.getWinSize().height/back:getContentSize().height)
	mLayer:addWidget(armyRootLayerxx)
	armyRootLayerxx:addChild(back)

	init()
end

function addFirstGuideLine(  )
	newGuideFistLine = {}
	local rootSprite = heroData[2].small_icon
	local point = rootSprite:convertToWorldSpace(cc.p(67/2,rootSprite:getContentSize().height))
	point = heroData[2].target:getParent():convertToNodeSpace(point)
	-- local attackIcon = cc.Sprite:createWithSpriteFrameName("xianshou_juli_3.png")
	-- heroData[2].target:getParent():addChild(attackIcon,99)
	-- attackIcon:setPosition(point)
	-- table.insert(newGuideFistLine,attackIcon)

	local firstSprite = heroData[6].small_icon
	local point1 = firstSprite:convertToWorldSpace(cc.p(67/2,0))
	point1 = heroData[6].target:getParent():convertToNodeSpace(point1)

	local point2 = firstSprite:convertToWorldSpace(cc.p(67/2,firstSprite:getContentSize().height))
	point2 = heroData[6].target:getParent():convertToNodeSpace(point2)
	local first = cc.Sprite:createWithSpriteFrameName("xianshou_juli_1.png")
	first:setAnchorPoint(cc.p(0.5,0))
	heroData[6].target:getParent():addChild(first,99)
	first:setPosition(point2)
	table.insert(newGuideFistLine,first)
	first:setVisible(false)
	
	local rotation = animation.pointRotate({x= point.x, y=point.y}, {x= point1.x, y = point1.y })
	local length = math.sqrt(math.pow((point.x - point1.x),2) + math.pow((point.y - point1.y),2))
	local width = 35
	local line_layer = TouchGroup:create()
	local pColor = nil
	local count = math.floor(length/width)
	for m=1, count do
		pColor = ImageView:create()
		pColor:loadTexture("xianshou_juli_4.png",UI_TEX_TYPE_PLIST)
		line_layer:addWidget(pColor)
		pColor:setPosition(cc.p(width*0.5+(m-1)*width, pColor:getContentSize().height/2))
	end
	line_layer:setContentSize(CCSize(length, pColor:getContentSize().height))
	line_layer:ignoreAnchorPointForPosition(false)
	line_layer:setAnchorPoint(cc.p(0,0.5))
	line_layer:setRotation(-rotation)
	line_layer:setPosition(cc.p(point.x, point.y))
	heroData[2].target:getParent():addChild(line_layer)
	table.insert(newGuideFistLine,line_layer)

	line_layer:runAction(animation.sequence({CCFadeIn:create(0.5),cc.CallFunc:create(function (  )
		first:setVisible(true)
		first:runAction(CCFadeIn:create(0.2))
	end)}))
	-- for i, v in pairs(newGuideFistLine) do
	-- 	v:runAction(CCFadeIn:create(0.5))
	-- end
end

function addSecondGuideLine( )
	newGuideSecondLine = {}
	local rootSprite = heroData[2].small_icon
	local point = rootSprite:convertToWorldSpace(cc.p(67/2,rootSprite:getContentSize().height))
	point = heroData[2].target:getParent():convertToNodeSpace(point)

	local firstSprite = heroData[7].small_icon
	local point1 = firstSprite:getParent():convertToWorldSpace(cc.p(firstSprite:getPositionX(),firstSprite:getPositionY()))
	point1 = heroData[7].target:getParent():convertToNodeSpace(point1)

	local point2 = firstSprite:convertToWorldSpace(cc.p(67/2,firstSprite:getContentSize().height))
	point2 = heroData[6].target:getParent():convertToNodeSpace(point2)
	local first = cc.Sprite:createWithSpriteFrameName("xianshou_juli_2.png")
	first:setAnchorPoint(cc.p(0.5,0))
	heroData[7].target:getParent():addChild(first,99)
	first:setPosition(point2)
	table.insert(newGuideSecondLine,first)
	first:setVisible(false)
	
	local rotation = animation.pointRotate({x= point.x, y=point.y}, {x= point1.x, y = point1.y })
	local length = math.sqrt(math.pow((point.x - point1.x),2) + math.pow((point.y - point1.y),2))
	local width = 35
	local line_layer = TouchGroup:create()
	local pColor = nil
	local count = math.floor(length/width)
	for m=1, count do
		pColor = ImageView:create()
		pColor:loadTexture("xianshou_juli_4.png",UI_TEX_TYPE_PLIST)
		line_layer:addWidget(pColor)
		pColor:setPosition(cc.p(width*0.5+(m-1)*width, pColor:getContentSize().height/2))
	end
	line_layer:setContentSize(CCSize(length, pColor:getContentSize().height))
	line_layer:ignoreAnchorPointForPosition(false)
	line_layer:setAnchorPoint(cc.p(0,0.5))
	line_layer:setRotation(-rotation)
	line_layer:setPosition(cc.p(point.x, point.y))
	heroData[2].target:getParent():addChild(line_layer)
	table.insert(newGuideSecondLine,line_layer)

	line_layer:runAction(animation.sequence({CCFadeIn:create(0.5),cc.CallFunc:create(function (  )
		first:setVisible(true)
		first:runAction(CCFadeIn:create(0.2))
	end)}))

	-- for i, v in pairs(newGuideSecondLine) do
	-- 	v:runAction(CCFadeIn:create(0.5))
	-- end
end

function removeFirstGuideLine(  )
	if newGuideFistLine then
		for i, v in pairs(newGuideFistLine) do
			v:removeFromParentAndCleanup(true)
		end
	end
	newGuideFistLine = nil
end

function removeSecondGuideLine(  )
	if newGuideSecondLine then
		for i, v in pairs(newGuideSecondLine) do
			v:removeFromParentAndCleanup(true)
		end
	end
	newGuideSecondLine = nil
end

function getBackGroundImage( )
	return armyRootLayerxx
end

function getFormation( )
	return formation,_width, _height,midX,midY, gridWidth,gridHeight
end

function getLeaderInfo( pos )
	return armyInfo[pos*100+1]
end

function getArmyLeader( pos )
	return armyLeaderInfo[pos*100+1]
end

function getArmySoldiers(pos)
	return armyInfo[pos]
end

function getIsStop( )
	return isStop
end

function setCloseBtnVisible(flag )
	local temp_widget = mLayer:getWidgetByTag(999)
	if temp_widget then
		tolua.cast(temp_widget:getChildByName("close_btn"), "Button"):setVisible(flag)
	end
end

function dealwithTouchEvent(x,y)
	if not mLayer then
		return false
	end

	-- local temp_widget = m_mainLayer:getWidgetByTag(999)
	-- if temp_widget:hitTest(cc.p(x,y)) then
		-- return false
	-- else
		-- remove_self()
		return false
	-- end
end

function getIconInfo(pos )
	if heroData[pos] then
		local icon_width = heroData[pos].small_icon:getSize().width
		local icon_height = heroData[pos].small_icon:getSize().height
		local temp_point = heroData[pos].small_icon:convertToWorldSpace(cc.p(icon_width/2, icon_height/2))
		return icon_width, icon_height, temp_point
	end
	return false
end

function get_map_mask_area(temp_guide_id, is_show_sign)
	local show_width, show_height, show_point = nil, nil, nil
	if temp_guide_id == guide_id_list.CONST_GUIDE_1023 then
		show_width, show_height, show_point = getIconInfo(7)
		return show_point, CCSizeMake(show_width, show_height), CCSizeMake(show_width, show_height)
	elseif temp_guide_id == guide_id_list.CONST_GUIDE_1025 then
		show_width, show_height, show_point = getIconInfo(6)
		return show_point, CCSizeMake(show_width, show_height), CCSizeMake(show_width, show_height)
	elseif temp_guide_id == guide_id_list.CONST_GUIDE_1026 then
		show_width, show_height, show_point = getIconInfo(7)
		return show_point, CCSizeMake(show_width, show_height), CCSizeMake(show_width, show_height)
	end
end

function get_guide_widget(temp_guide_id)
	if temp_guide_id == guide_id_list.CONST_GUIDE_1051 then
		if mLayer then
			return mLayer:getWidgetByTag(999)
		else
			return nil
		end
	else
		return BattleResultSum.getInstance()
	end
end

function getScale( )
	return m_scale
end

function closeWidgetFunc( )
	closeFun = true
end