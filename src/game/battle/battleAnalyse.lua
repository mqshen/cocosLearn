--动画战报每一次的解析
module("BattleAnalyse", package.seeall)
local stepTable = {}
local m_step = 1
local m_warBegin = nil
local isBeforePlay = nil
-- local heroData = nil
function getFirst( )
	if m_step == 1 then
		return true
	else
		return false
	end
end

function setBeforePlay( )
	isBeforePlay = true
end

function remove(  )
	m_step = 1
	m_warBegin = nil
	isBeforePlay = nil
	-- BattleAnimationController.remove()
	-- for i, v in pairs(heroData) do
	-- 	if v.target then
	-- 		v.target:removeFromParentAndCleanup(true)
	-- 	end
	-- end
	-- heroData = nil
	stepTable = {}
	BattleAnimation.remove()
end

function setWarFlag( )
	m_warBegin = true
end

-- --获取武将的对象，包括widget
-- function getHeroTarget( heroPos)
-- 	if not heroPos then
-- 		print(">>>>>>>>>>>>>>>>>>>>>>>>heroPos is nil")
-- 		return false
-- 	end
-- 	return heroData[heroPos]
-- end

-- function getInstance( )
-- 	return cc.Director:getInstance():getRunningScene()
-- end

function playNext( unique_index )
	if BattleAnimationController.getIsStop( ) then return end
	if not isBeforePlay and not BattleAnimationController.getInstance() then return end
	local heroPos = math.floor(unique_index/100)
	-- 这次解析的第几条
	local count = unique_index%100
	-- print(">>>>>>>>>>>>>>>>step ="..m_step.."     heroPos="..heroPos)
	if stepTable[m_step] and stepTable[m_step][heroPos] then
		local total_count = #stepTable[m_step][heroPos].info
		-- print(">>>>>>>>>>>>>>>>>>>heroPos ="..heroPos.." count="..count.."      total_count="..total_count)
		stepTable[m_step][heroPos].count = count
		-- 这个位置的武将，当前loop还没解析完
		if count < total_count then
			print(">>>>>>>>>>>>>>1111111>>>mama ="..warRoundKeyword[stepTable[m_step][heroPos].info[count+1][1]][1])
			BattleAnimation.create(stepTable[m_step][heroPos].info[count+1][2], heroPos*100+count+1, isBeforePlay)
			return 
		-- 这个位置的武将当前loop已经解析完
		else
			for i, v in pairs(stepTable[m_step]) do
				--当前loop， 还有武将解析没完成时，不走下一步，等待返回
				if v.count < #v.info then
					return
				end
			end
		end

		-- 当前loop已经解析完，继续解析下一个
		m_step = m_step + 1
		analyseAnimation()
	else
		print(">>>>>>>>>>>>>>>battle error m_step ="..m_step)
	end
end

function analyseAnimation()
	if BattleAnimationController.getIsStop( ) then return end
	if not isBeforePlay and not BattleAnimationController.getInstance() then return end
	local data = BattlaAnimationData.getBattleData()[m_step]
	if not data then
		return
	end

	if not BattleAnimationController.getIsAttack() and m_warBegin then
		BattleAnimationController.getInstance():runAction(animation.sequence({cc.DelayTime:create(0.1),cc.CallFunc:create(function ( )
			analyseAnimation()
		end)}))
		return
	end
	--单步执行
	-- if data.begin == 1 or data.begin == 3 or data.begin == 0 then
	-- 	BattleAnimation.create()
	--并行
	-- elseif data.begin == 2 or data.begin == 5 then
	if data.begin ~= 99 and data.begin ~= 4 then
		stepTable[m_step] = {}
		-- local heroPosTable = {}
		local heroPos = nil
		

		-- if #data.info==1 then
			-- print(">>>>>>>>>>>>>>>>>mama ="..warRoundKeyword[data.info[1][1]][1])
		-- else
			if #data.info == 0 then
				m_step = m_step + 1
				analyseAnimation()
				return
			end 

			for i,v in ipairs(data.info) do
				--以武将位置+1为key,找到针对每个武将的解析，构成一个完整的表现形式
				local index = tonumber(string.sub(warRoundKeyword[v[1]][2],4,4))
				if index then
					heroPos = v[2][index+1]+1
					if not stepTable[m_step][heroPos] then
						stepTable[m_step][heroPos] = { count = 0, info = {}}
						-- table.insert(stepTable[m_step], v)
					end
					table.insert(stepTable[m_step][heroPos].info, v)
				else
					stepTable[m_step][99] = { count = 0, info = {v}}
				end
			end

			for i, v in pairs(stepTable[m_step]) do
				print(">>>>>>>>>>>>>>>>>mama ="..warRoundKeyword[v.info[1][1]][1])
				BattleAnimation.create(v.info[1][2], i*100+1, isBeforePlay)
			end
		-- end


	-- elseif data.begin == 99 then
	-- elseif data.begin == 4 then
		
	else
		m_step = m_step + 1
		analyseAnimation()
	end
end