local uiUtil = require("game/utils/ui_util")


local BuildingAreaData = {}

--[[表中各个元素含义：   1 所处显示的标签页 1 军事页；2 民政页；3 守备页
                            2 建筑显示的图标类型     -- 1 校场区域 dune_icon.png;    2 点将台区域 touxiange_icon.png; 3 封禅台 shue_icon.png
                                                    -- 4 居民区域 mingju_icon.png;  5 城防区域/要塞   chengqiang_icon.png;    6 社稷坛 shejitan_icon.png
                            3 所处坐标X
                                4 所处坐标Y
        --]]
function BuildingAreaData.getUILocationInfo()
    local build_location = {}
    
    build_location[10] = {{0,1,108,203}}
    build_location[11] = {{0,1,108,203}}
    build_location[13] = {{0,2,8,63}}
    build_location[20] = {{0,2,154,63}}
    build_location[21] = {{0,2,300,118}}
    build_location[23] = {{0,2,300,8}}
    build_location[22] = {{0,2,446,118}}
    build_location[24] = {{0,2,446,8}}
    build_location[25] = {{0,2,592,63},{6,2,592,118},{7,2,592,118}}
    build_location[81] = {{6,2,592,8}}
    build_location[82] = {{7,2,592,8}}
    build_location[40] = {{0,3,8,63}}
    build_location[30] = {{0,3,592,63}}
    build_location[36] = {{0,3,446,63}}
    build_location[51] = {{0,3,300,118}}
    build_location[52] = {{0,3,154,118}}
    build_location[53] = {{0,3,300,8}}
    build_location[54] = {{0,3,154,8}}
    build_location[31] = {{0,4,8,63}}
    build_location[32] = {{0,4,154,63}}
    build_location[33] = {{0,4,300,118}}
    build_location[34] = {{0,4,300,8}}
    build_location[35] = {{0,4,592,63},{9,4,592,118}}
    build_location[42] = {{0,4,446,63}}
    build_location[84] = {{9,4,592,8}}
    build_location[64] = {{0,5,300,118}}
    build_location[67] = {{0,5,154,63}}
    build_location[61] = {{0,5,8,63}}
    build_location[62] = {{0,5,8,63}}
    build_location[65] = {{0,5,300,8}}
    build_location[68] = {{0,5,300,63}}
    build_location[63] = {{0,5,154,63}}
    build_location[83] = {{8,5,446,63}}
    build_location[43] = {{0,6,24,179}}
    build_location[44] = {{0,7,24,179}}

    return build_location
end


-- 1 城主府 2 经济区 3 士兵区 4武将区 5 城防区 6 社稷坛 7 封禅坛
-- return tab  {buildId,posInfo}
function BuildingAreaData.getAreaConfigInfo(areaType)
    local retTab = {}

    local userCityInfo = userCityData.getUserCityData(mainBuildScene.getThisCityid())
    if not userCityInfo then return retTab end

    local function whichType( city)
        --主城或分城
        if city == 1 and (userCityInfo.city_type ==cityTypeDefine.fencheng or userCityInfo.city_type ==cityTypeDefine.zhucheng) then
            return true
        elseif city ==3 and userCityInfo.city_type ==cityTypeDefine.fencheng then
            return true
        elseif city ==4 and userCityInfo.city_type ==cityTypeDefine.yaosai then
            return true
        else
            return false
        end
    end

    local getpos = function (resLevelTable,resLevel)
        local flag = false
        for i, v in ipairs(resLevelTable) do
            if v == 0 then
                flag = true
            else
                if resLevel == v then
                    return i
                end
            end
        end

        if flag then
            return 1
        end
        return nil
    end

    local buildLocation = BuildingAreaData.getUILocationInfo()
    local curCid = mainBuildScene.getThisCityid()
    local resLevel = resourceData.resourceLevel(math.floor(curCid/10000), curCid%10000)
    local lipIndex = nil
    local resLevelTable = nil
    for i, v in pairs(buildLocation) do
        resLevelTable = {}
        for m, n in ipairs(v) do
            table.insert(resLevelTable, n[1])
        end
        lipIndex = getpos(resLevelTable,math.floor(resLevel/10))
        if lipIndex and v[lipIndex][2] == areaType  and  whichType(Tb_cfg_build[i].city_type) then
            -- setBuildingPos(v[lipIndex],i)
            retTab[i] = v[lipIndex]
        end
    end


    return retTab
end

BuildingAreaData.buildSame = {
    [62] = 61,
    [67] = 64,
    [68] = 65
}



-- 城主府，军事设施，内政设施  三个UI 分配的建筑区域类型
BuildingAreaData.areaTypeAllocate = {
    {1},
    {4,3,7},
    {2,5,6},
}

-- 城主府，军事设施，内政设施  三个UI对应的title名字
BuildingAreaData.buildingAreaTitles = {
    languagePack["buildingAreaTitleMainCity"],
    languagePack["buildingAreaTitleMilitary"],
    languagePack["buildingAreaTitleInterior"],
}

return BuildingAreaData