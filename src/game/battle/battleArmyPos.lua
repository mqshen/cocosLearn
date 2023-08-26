--部队界面需要调用这个逻辑去显示阵型
module("BattleArmyPos", package.seeall)

local function playAnimation(node, name, index )
	local i = index
	node:runAction(CCRepeatForever:create(animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
		node:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name..i..".png"))
		i = i + 1
		if i>6 then
			i = 1
		end
	end)})))
end

-- data的封装格式如下
-- data = {}
-- data.position = xx --部队中的位置，1 大营 2 中军 3 前锋
-- data.heroid = xx --英雄id
-- data.army = xx -- 部队数量
function returnOneArmyPos( data)
	require("game/battle/battleAnimationController")
	require("game/battle/battleFormationDefined")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/battle/battle_dir_1_2.plist")
	local name = {"player_1_1_walk_", "player_2_1_walk_","player_3_1_walk_"}
	local leadName = {"player_leader_1_"}
	local dayingName = {"player_base_1_"}
	local pos = nil
	local realPos = nil
	local tempid = nil
	local armyCount = nil
	local hit_range = 0
	local tempArmydata = data
	local id = nil
	local formation, _width, _height, midX,midY,gridWidth,gridHeight = BattleAnimationController.getFormation()
	local m_scale = 1.2*config.getWinSize().width/(_width*gridHeight)
	local cfg_hero_data = nil

	local singel_data = nil
	local battleBatchNode = CCSpriteBatchNode:create("gameResources/battle/battle_dir_1_2.png")
	battleBatchNode:setScale(m_scale)
	pos = tempArmydata.position + 1

	local coorx, coory = nil
	local x, y = nil
	--大营
	if pos == 2 then
		realPos = 3
	elseif pos == 3 then
		realPos = 2
	elseif pos == 4 then
		realPos = 1
	end

	if realPos <=3 then
		tempid = name[Tb_cfg_hero[tempArmydata.heroid].hero_type]
		
		zhengorfu = 1
	end

	armyCount = BattleAnimationController.realCount( tempArmydata.army )
	for m = 1, armyCount do
		cfg_hero_data = Tb_cfg_hero[tempArmydata.heroid]
		hit_range = cfg_hero_data.hit_range
		-- 弓
		if cfg_hero_data.hero_type == 1 then
			-- 这个是为了防止配表错误,弓兵的攻击范围不可能是1
			if hit_range == 1 then
				hit_range = 2 
			end
		end

		singel_data = battleFormation[cfg_hero_data.hero_type*10+hit_range][m]
		coorx, coory = math.floor(gridWidth/2) + zhengorfu*1*singel_data[1], math.floor(gridHeight/2)+zhengorfu*1*singel_data[2]

		if m == 1 then
			midX,midY = coorx, coory
		end

		-- x, y = BattleAnimationController.getMapSpritePos(0,0, midX,midY, coorx,coory, _width, _height  )

		if m == 1 and realPos <=3 then
			id = leadName[1]
			-- 攻方大营或者守方大营
			if pos == 2 or pos == 7 then
				id = dayingName[1]
			end
		elseif m==1 and realPos >3 then
			id = leadName[cfg_hero_data.hero_type*2]
			if pos == 2 or pos == 7 then
				id = dayingName[2]
			end
		else
			id = tempid
		end

		-- local sprite = cc.Sprite:createWithSpriteFrameName(id.."1"..".png")
		-- battleBatchNode:addChild(sprite)
		-- sprite:setAnchorPoint(cc.p(0.5,0.2))
		-- sprite:setPosition(cc.p(x, y))

		local sprite = cc.Sprite:createWithSpriteFrameName(id.."1.png")
		battleBatchNode:addChild(sprite, coorx*10000- coory, coorx*10000- coory)
		if cfg_hero_data.hero_type == 3 or m == 1 then
			sprite:setAnchorPoint(cc.p(0.5,0.3))
		else
			sprite:setAnchorPoint(cc.p(0.5,10/sprite:getContentSize().height))
		end

		local realx, realy = BattleAnimationController.getMapSpritePos(0,0, midX,midY, coorx,coory, _width, _height  )
		sprite:setPosition(cc.p(realx, realy))
		-- sprite:setScale(config.scaleIn3D( worldx,worldy,10, _width, _height ))

		playAnimation(sprite,id, math.random(1,6) )
	end
	return battleBatchNode
end