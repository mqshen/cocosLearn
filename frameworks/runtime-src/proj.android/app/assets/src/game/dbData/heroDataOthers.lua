module("heroDataOthers", package.seeall)

local instance = nil

-- 演武系统的武将列表
local cache_hero_list_of_exercise = nil



function getHeroInfo(heroUid)
	if cache_hero_list_of_exercise[heroUid] then 
		return cache_hero_list_of_exercise[heroUid]
	else
		return false
	end
end


function testShow()
	require("game/cardDisplay/userCardViewer")
	local hero_uid_list = {}
	local hero_id_u
	for k,v in pairs(cache_hero_list_of_exercise) do 
		hero_id_u = v.heroid_u
		table.insert(hero_uid_list,v.heroid_u)
	end

	userCardViewer.create(hero_uid_list,hero_id_u)
end

-- 适配演武系统的武将数据
local function convertExerciseHeroInfo(cfgHeroInfoU)
	if cfgHeroInfoU ~= cjson.null then
		cfgHeroInfoU.advance_num = 0
		
		cfgHeroInfoU.hurt_end_time = 0
		cfgHeroInfoU.hp_end_time = 0

		-- 经验相关
		cfgHeroInfoU.exp = 0

		-- 体力相关
		cfgHeroInfoU.energy_add = 0
		cfgHeroInfoU.energy = HERO_ENERGY_MAX
		cfgHeroInfoU.energy_time = 0

		-- 部队
		cfgHeroInfoU.armyid = -1

		-- 剩余可配置点数
		cfgHeroInfoU.point_left = 0

		-- cfgHeroInfoU.awake_state = 1

		-- config.dump(cfgHeroInfoU)
		return cfgHeroInfoU
	else
		return false
	end
end
-- 缓存住演武的武将数据
function cacheArmyHeroListOfExercise( heroList)

	for k,v in pairs(heroList) do 
		local heroInfo = convertExerciseHeroInfo(v)
		if heroInfo then 
			cache_hero_list_of_exercise[heroInfo.heroid_u] = heroInfo
		end
	end
end


-- 演武 部队的 hero list
local function responeReceiveArmyHerosInExercise(...)
	-- config.dump({...})
end


function requestArmyHerosInExercise(army_id)
	army_id = 9040414
	Net.send(EXERCISE_GET_ARMY_INFO,{army_id})
end


local function disposeCMDListener()
	-- netObserver.removeObserver(EXERCISE_GET_ARMY_INFO)
end

local function initCMDListener()
	-- netObserver.addObserver(EXERCISE_GET_ARMY_INFO,responeReceiveArmyHerosInExercise)
end

local function init()
	if instance then return end
	initCMDListener()
	cache_hero_list_of_exercise = {}
end

function remove()
	if not instance then return end
	cache_hero_list_of_exercise = nil
	disposeCMDListener()
end

function create()
	init()

end