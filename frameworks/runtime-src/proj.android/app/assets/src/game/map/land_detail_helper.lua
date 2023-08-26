local landDetailHelper = {}

local function getNpcCityLevel(landId)
   local level = ni
   local cfgCityInfo = Tb_cfg_world_city[landId]
   if cfgCityInfo then 
        level = cfgCityInfo.param % 10
   end
   if level == 0 then level = 10 end
   return level
end



-- NPC城区 守军等级 --> 守军强度 配置
local defend_convert_armyLv_to_strength_npcProper = {4,5,6,7,8,9,10,11,12,13,}
-- NPC城市（含关卡） 守军等级 --> 守军强度 配置
local defend_convert_armyLv_to_strength_npcCity = {4,5,6,7,8,9,10,11,12,13,}
-- 码头 守军等级 --> 守军强度 配置
local defend_convert_armyLv_to_strength_npcMatou = {5,5,5,5,}
-- 军营 守军等级 --> 守军强度 配置
local defend_convert_armyLv_to_strength_npcJunying = {5,5,5,5,}
-- 要塞 守军等级 --> 守军强度 配置
local defend_convert_armyLv_to_strength_npcYaosai = {4,4,4,4,}

local function convertDefenderArmyLv2StrengthLv(coorX,coorY,cityType,defenderArmyLv)
    if not cityType then return defenderArmyLv end

    local tmpCfgData = nil
    if cityType == cityTypeDefine.npc_chengqu then 
        tmpCfgData = defend_convert_armyLv_to_strength_npcProper
    elseif cityType == cityTypeDefine.npc_cheng then 
        tmpCfgData = defend_convert_armyLv_to_strength_npcCity
    elseif cityType == cityTypeDefine.matou then 
        tmpCfgData = defend_convert_armyLv_to_strength_npcMatou
    elseif cityType == cityTypeDefine.npc_yaosai then 
        --TODOTK  军营和要塞 为毛要占位同一个类型
        if Tb_cfg_world_city[coorX*10000+coorY].param >=NPC_FORT_TYPE_RECRUIT[1] and
            Tb_cfg_world_city[coorX*10000+coorY].param <=NPC_FORT_TYPE_RECRUIT[2] then
            tmpCfgData = defend_convert_armyLv_to_strength_npcJunying
        else
            tmpCfgData = defend_convert_armyLv_to_strength_npcYaosai
        end
    end

    if tmpCfgData and tmpCfgData[defenderArmyLv] then 
        return tmpCfgData[defenderArmyLv]
    else
        return defenderArmyLv
    end
end


-- 获取地块的守军强度
function landDetailHelper.getDefenderStrengthLv(coorX,coorY)
    local cityType = landData.get_land_type(coorX * 10000 + coorY)
    local landResLv = resourceData.resourceLevel(coorX, coorY)
    local landResDefenderLv = math.floor(landResLv/10)
    return convertDefenderArmyLv2StrengthLv(coorX,coorY,cityType,landResDefenderLv)
end
function landDetailHelper.getInfo(coorX,coorY)
    local m_tDetailInfo = {}
    m_tDetailInfo["coorX"]                      = coorX
    m_tDetailInfo["coorY"]                      = coorY
    m_tDetailInfo["landId"]                     = coorX * 10000 + coorY
    m_tDetailInfo["landName"]                   = " "
    m_tDetailInfo["landLv"]                     = 0
    m_tDetailInfo["landResLv"]                  = 0
    m_tDetailInfo["landResDefenderLv"]          = 0
    m_tDetailInfo["regionName"]                 = languagePack["region_border"]
    m_tDetailInfo["isOwnFree"]                  = false --是否是无主的
    m_tDetailInfo["isOwnSelf"]                  = false --是否是自己的
    m_tDetailInfo["isResourcesLand"]            = false --是否是资源地
    m_tDetailInfo["isMountain"]                 = false --是否是山脉
    m_tDetailInfo["isWater"]                    = false --是否是水
    m_tDetailInfo["isNPCCity"]                  = false --是否是NPC城市
    m_tDetailInfo["isNPCProper"]                = false --是否是NPC城区
    m_tDetailInfo["isMatou"]                    = false --是否是码头
    m_tDetailInfo["isUserMainCity"]             = false --是否是玩家主城
    m_tDetailInfo["isUserMainCityProper"]       = false --是否是玩家城区
    m_tDetailInfo["isUserCity"]                 = false --是否是玩家分城
    m_tDetailInfo["isNpcYaosai"]                = false --是否是野外的npc要塞或者野外军营
    m_tDetailInfo["isUserFort"]                 = false --是否是玩家要塞
    m_tDetailInfo["isUserTerritory"]            = false --是否是玩家的领地
    m_tDetailInfo["isNeedDataFromServer"]       = true  --是否要从服务端获取数据  （土地耐久度以及同盟名字信息）
    m_tDetailInfo["isDurabilityInfoVisible"]    = false --是否显示耐久度
    m_tDetailInfo["isRedifVisible"]             = false --是否显示预备兵
    m_tDetailInfo["durability_cur"]             = 1        
    m_tDetailInfo["durability_max"]             = 1 
    m_tDetailInfo["owner_name"]                 = ""
    m_tDetailInfo["owner_union_name"]           = ""
    m_tDetailInfo["affilate_union_name"]        = ""
    m_tDetailInfo["isDefenderLvVisible"]        = true  --是否显示守军强度等级信息
    m_tDetailInfo["isDefenderVisible"]          = true  --是否显示守军强度
    m_tDetailInfo["flag_show_res_out"]          = true  --是否显示产量
    m_tDetailInfo["userId"]                     = nil
    m_tDetailInfo["union_id"]                   = nil
    m_tDetailInfo["affilated_union_id"]         = nil
    m_tDetailInfo["isLunxianVisible"]           = false
    --attention 无主的土地无法准确获取类型
    local landType = landData.get_land_type(m_tDetailInfo.landId)

    local temp_city_info = Tb_cfg_world_city[m_tDetailInfo.landId]
    local message = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[coorX] and buildingData[coorX][coorY] then
        message = buildingData[coorX][coorY]

        if message.userId then 
            m_tDetailInfo.userId = message.userId
        end

        if message.affilated_union_id then 
            m_tDetailInfo.affilated_union_id = message.affilated_union_id
        end

        if message.union_id then 
            m_tDetailInfo.union_id = message.union_id
        end
    end
    local relation = nil
    if message then 
        relation = mapData.getRelationship(message.userId,message.union_id,message.affilated_union_id)
    end

    --是否是无主的
    if message and relation and relation == mapAreaRelation.all_free then 
        m_tDetailInfo.isOwnFree = true
    end
    if landData.is_own_free(m_tDetailInfo.landId) then 
        m_tDetailInfo.isOwnFree = true
    end
    -- 是否是自己的
    if mapData.isSelfLand(coorX , coorY) then 
        m_tDetailInfo.isOwnSelf = true
    end

    -- if landData.own_land(m_tDetailInfo.landId) then 
    --     m_tDetailInfo.isOwnSelf = true
    -- end

    --是否是码头
    if temp_city_info and temp_city_info.city_type == cityTypeDefine.matou then
        m_tDetailInfo.isMatou = true
    end

    local is_lingdi = false


    -- 是否显示资源地信息
    if message then
        if message.cityType == cityTypeDefine.lingdi then 
            is_lingdi = true
        end

        -- 如果是野外的军营，且是属于自己或者无主， 需要显示预备兵数
        local area = nil
        if Tb_cfg_world_city[m_tDetailInfo["landId"]] then
            area= Tb_cfg_world_city[m_tDetailInfo["landId"]].param
        end
        if message.cityType == cityTypeDefine.npc_yaosai and area and (m_tDetailInfo.isOwnSelf or m_tDetailInfo.isOwnFree ) and area >= NPC_FORT_TYPE_RECRUIT[1] and area <= NPC_FORT_TYPE_RECRUIT[2] then
            m_tDetailInfo.isRedifVisible = true
        end

        if message.cityType and message.cityType == 0 then 
            -- 放弃领地后 客户端好像没有清理对应的数据 导致放弃后的领地的cityType == 0 
            m_tDetailInfo.isResourcesLand = true
        end
    else
        -- --是否是山脉
        -- m_tDetailInfo.isMountain = mapData.getCityType(coorX, coorY)        
        -- --是否是水
        -- m_tDetailInfo.isWater = terrain.isWaterTerrain(coorX, coorY) 

        -- -- 是否是资源地
        -- if not m_tDetailInfo.isMountain and not m_tDetailInfo.isWater then 
        --     m_tDetailInfo.isResourcesLand = true
        -- else
        --     m_tDetailInfo.isResourcesLand = false
        -- end 
    end


    --是否是山脉
    m_tDetailInfo.isMountain = mapData.getCityType(coorX, coorY)        
    --是否是水
    m_tDetailInfo.isWater = terrain.isWaterTerrain(coorX, coorY) 

    -- 是否是资源地
    if not m_tDetailInfo.isMountain and not m_tDetailInfo.isWater then 
        m_tDetailInfo.isResourcesLand = true
    else
        m_tDetailInfo.isResourcesLand = false
    end
        
    -- if is_lingdi or m_tDetailInfo.isResourcesLand then 
    --     m_tDetailInfo.flag_show_res_out = true
    -- end


    if not Tb_cfg_world_city[m_tDetailInfo.landId] then 
        if not m_tDetailInfo.isMountain and not m_tDetailInfo.isWater then 
            m_tDetailInfo.isResourcesLand = true
        end
    end

    

           
    
    
    -- NPC城市
    m_tDetailInfo.isNPCCity = landData.is_type_npc_city(m_tDetailInfo.landId)
    -- NPC城区
    m_tDetailInfo.isNPCProper = landData.isNpcChengqu(m_tDetailInfo.landId)
    --是否是主城
    m_tDetailInfo.isUserMainCity    = landData.is_type_main_city(m_tDetailInfo.landId)
    --是否是主城城区
    m_tDetailInfo.isUserMainCityProper = landData.isPlayerChengqu(m_tDetailInfo.landId)
    --是否是玩家分城
    if landType and landType == cityTypeDefine.fencheng then 
        m_tDetailInfo.isUserCity = true 
    end
    --是否是玩家要塞
    if landType and landType == cityTypeDefine.yaosai then 
        m_tDetailInfo.isUserFort = true 
    end
    --是否是玩家的领地
    if landType and landType == cityTypeDefine.lingdi then 
        m_tDetailInfo.isUserTerritory = true 
    end

    if landType and landType == cityTypeDefine.npc_yaosai then
        m_tDetailInfo.isNpcYaosai = true
    end
    
    
    
    if m_tDetailInfo.isMountain or m_tDetailInfo.isWater or m_tDetailInfo.isUserCity or m_tDetailInfo.isNpcYaosai or
        m_tDetailInfo.isUserMainCity or m_tDetailInfo.isUserMainCityProper or
        m_tDetailInfo.isUserFort  then 
        m_tDetailInfo.flag_show_res_out = false
    end

    if not m_tDetailInfo.flag_show_res_out then
        local is_npc_city = false
        local is_matou = false
        local is_npc_cunzhuang = false
        local is_player_chengqu = false
        local temp_city_info = Tb_cfg_world_city[m_tDetailInfo.landId]
        if temp_city_info and temp_city_info.city_type == cityTypeDefine.npc_cheng then
            is_npc_city = true
        elseif temp_city_info and temp_city_info.city_type == cityTypeDefine.player_chengqu then
            is_player_chengqu = true
        elseif temp_city_info and temp_city_info.city_type == cityTypeDefine.matou then
            is_matou = true
        elseif temp_city_info and temp_city_info.city_type == cityTypeDefine.npc_chengqu then
            is_npc_cunzhuang = true
        end

        if is_npc_city or is_npc_cunzhuang then 
            m_tDetailInfo.flag_show_res_out = true
        end
    end
    
    --是否要从服务端获取数据  （土地耐久度以及同盟名字信息）
    -- if message then 
    --     if (message.userId and message.userId ~= 0) or (message.union_id and message.union_id ~= 0) then
    --         m_tDetailInfo.isNeedDataFromServer = true
    --     else
    --         if landData.isChengqu(m_tDetailInfo.landId) or m_tDetailInfo.isNPCCity or  m_tDetailInfo.isUserMainCityProper or m_tDetailInfo.isMatou then
    --             m_tDetailInfo.isNeedDataFromServer = true
    --         end 
    --     end

    -- end

    -- 是否需要显示土地耐久度
    if m_tDetailInfo.isOwnFree then 
        --无主的
        if m_tDetailInfo.isMountain or m_tDetailInfo.isWater then
            m_tDetailInfo.isDurabilityInfoVisible = false
        else
            m_tDetailInfo.isDurabilityInfoVisible = true
        end
    else
        if m_tDetailInfo.isOwnSelf then 
            m_tDetailInfo.isDurabilityInfoVisible = true
        else
            if relation then 
                if relation == mapAreaRelation.own_self or
                    relation == mapAreaRelation.attach_same_higher or
                    (relation == mapAreaRelation.all_free and m_tDetailInfo.isNPCCity) or 
                    (relation == mapAreaRelation.free_ally and message.union_id and message.union_id == userData.getUnion_id()) then 
                    m_tDetailInfo.isDurabilityInfoVisible = true
                end
            end
        end
    end

    --是否显示守军强度
    if m_tDetailInfo.isNPCCity or m_tDetailInfo.isNPCProper or m_tDetailInfo.isMatou then 
        m_tDetailInfo.isDefenderLvVisible = false
    else
        m_tDetailInfo.isDefenderLvVisible = true
    end

    if m_tDetailInfo.isUserMainCity or m_tDetailInfo.isUserCity or m_tDetailInfo.isUserFort or m_tDetailInfo.isUserMainCityProper
         then 
        m_tDetailInfo.isDefenderVisible = false
    else
        m_tDetailInfo.isDefenderVisible = true
    end

    -------------------------相关数据--------------------
    -- 名字以及等级
    m_tDetailInfo.landName ,m_tDetailInfo.landLv  = landData.get_city_name_lv_by_coordinate(m_tDetailInfo.landId)
    m_tDetailInfo.landResLv = resourceData.resourceLevel(m_tDetailInfo.coorX, m_tDetailInfo.coorY)
    m_tDetailInfo.landResDefenderLv = math.floor(m_tDetailInfo.landResLv/10)
    if not m_tDetailInfo.landLv then m_tDetailInfo.landLv = m_tDetailInfo.landResDefenderLv end

    if m_tDetailInfo.isNPCCity or m_tDetailInfo.isNPCProper or m_tDetailInfo.isMatou or m_tDetailInfo.isNpcYaosai then 
        m_tDetailInfo.landLv = getNpcCityLevel(m_tDetailInfo.landId)
    end
    m_tDetailInfo.landResDefenderLv = convertDefenderArmyLv2StrengthLv(m_tDetailInfo.coorX,m_tDetailInfo.coorY,landType, m_tDetailInfo.landLv)
    if m_tDetailInfo.isUserMainCityProper then 
        m_tDetailInfo.landLv = 0
    end

    -- 所在州
    local region_state = stateData.stateInMap(m_tDetailInfo.coorX,m_tDetailInfo.coorY)
    local region_info = Tb_cfg_region[region_state] 
    if region_state and region_info then 
        m_tDetailInfo.regionName = region_info.name 
    end


    -- 是否显示沦陷信息
    if m_tDetailInfo.affilated_union_id and m_tDetailInfo.affilated_union_id ~= 0 then
        if m_tDetailInfo.userId and (
            (m_tDetailInfo.userId == userData.getUserId() and m_tDetailInfo.isUserMainCity) or 
            m_tDetailInfo.userId ~= userData.getUserId() )  then
            m_tDetailInfo.isLunxianVisible = true
        end
    end



    m_tDetailInfo.durability_cur, m_tDetailInfo.durability_max = landData.getDurabilityInfo(m_tDetailInfo.coorX,m_tDetailInfo.coorY)

    if m_tDetailInfo.isOwnSelf then 
        m_tDetailInfo.isNeedDataFromServer = false
        m_tDetailInfo.owner_name = userData.getUserName()
        m_tDetailInfo.owner_union_name = userData.getUnion_name()
        m_tDetailInfo.affilate_union_name = userData.getAffilated_union_name()
    end

    if m_tDetailInfo.isOwnFree and (is_lingdi or m_tDetailInfo.isResourcesLand) then 
        m_tDetailInfo.isNeedDataFromServer = false
    end
    
    if m_tDetailInfo.isMountain then 
        m_tDetailInfo.isNeedDataFromServer = false
    end
    if m_tDetailInfo.isWater then 
        m_tDetailInfo.isNeedDataFromServer = false
    end

    if message and message.cityType and message.cityType == 0 then 
        -- 预防客户端的 mapData 没及时清理数据
        m_tDetailInfo.isNeedDataFromServer = false
    end



    -- 其实客户端没有这样的数据  得服务端处理 
    local worldCityInfo = landData.get_world_city_info(m_tDetailInfo.landId)
    -- 废墟的话 也不请求
    if worldCityInfo and worldCityInfo.city_type == 0 and worldCityInfo.userid == 0 then 
        m_tDetailInfo.isNeedDataFromServer = false
    end

    -- 不是自己的 NPC城 NPC城区 NPC要塞 码头 要请求数据
    if m_tDetailInfo.isNPCCity or m_tDetailInfo.isNPCProper or m_tDetailInfo.isNpcYaosai or m_tDetailInfo.isMatou  then 
        if not m_tDetailInfo.isOwnSelf then 
            m_tDetailInfo.isNeedDataFromServer = true
        end
    end

    -- 自己的城区 无主状态下需要请求数据
    if m_tDetailInfo.isUserMainCityProper and not m_tDetailInfo.isOwnSelf   then 
        if message and message.userid then 
            if message.userid == 0 then 
                m_tDetailInfo.isNeedDataFromServer = true
            end
        else
            m_tDetailInfo.isNeedDataFromServer = true
        end
    end


    -- NPC 城  要获取首占信息
    if m_tDetailInfo.isNPCCity then 
        m_tDetailInfo.isNeedDataFromServer = true
    end

    return m_tDetailInfo
end

return landDetailHelper
