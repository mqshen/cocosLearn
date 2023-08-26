local UIRoleForcesBase = {}
local uiUtil = require("game/utils/ui_util")
local instance = nil

local user_name = nil
local user_id = nil
local union_id = nil
local affilated_union_id = nil

local isRangerAble = nil
local is_own = nil
local user_renown = nil

local StringUtil = require("game/utils/string_util")

local detail_info_from_server = nil
function UIRoleForcesBase.remove()
	if instance then 
		instance:removeFromParentAndCleanup(true)
		instance = nil
		user_name = nil
		user_id = nil
		union_id = nil
		union_position = nil
		affilated_union_id = nil
		is_own = nil
		user_renown = nil
		isRangerAble = nil
		netObserver.removeObserver(GET_USER_PROFILE)
	end
	detail_info_from_server = nil
end

-- 领地列表
local function get_manor_list(user_id)
	local manor_list = {}
	for k ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
   		if v.userid == user_id then
   			table.insert(manor_list,v)
   		end
   	end
   	return manor_list
end

-- 获取分城上限
local function get_town_max(renown)
	-- cfg_city_renown
	local count = 0
	for k,v in pairs(Tb_cfg_city_renown) do 
		if renown * 100 >= v.renown and v.city_count > count then 
			count = v.city_count
		end
	end
	return count
end

-- 获取要塞上限
local function get_fort_max(renown)
	-- cfg_fort_renown
	local count = 0
	for k,v in pairs(Tb_cfg_fort_renown) do 
		if renown*100 >= v.renown and v.fort_count > count then 
			count = v.fort_count
		end
	end
	return count
end
-- 获取城市总面积 以及 总面积上限
local function get_city_area()
	--cfg_build_area
	local manor_list = get_manor_list(user_id)
	local city_info = nil
	local area = 0
	local area_max = 0
	for k,v in pairs(manor_list) do 
		city_info = userCityData.getUserCityData(v.wid)
		if city_info then 
			area = area + city_info.build_area_cur
			area_max = area_max + city_info.build_area_max
		end
	end
	return area,area_max
end

-- 获取总部队数上限 （只有主城和分城有部队，校场等级就是部队数上限）
local function getTotalArmyMax()
	local retCount = 0
	for k ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
   		if v.userid == user_id and 
   		 (v.city_type == cityTypeDefine.zhucheng or 
   		 	v.city_type == cityTypeDefine.fencheng) then
   		 	retCount = retCount + politics.getBuildLevel(v.wid, cityBuildDefine.jiaochang)
   		end
   	end
   	return retCount
end

local function deal_with_jump_union(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
    	if not union_id then return end  
    	local temp_union_id = union_id
    	UIRoleForcesMain.remove_self()
        UnionUIJudge.create(temp_union_id)
        
    end
end
local function deal_with_jump_affilated_union(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
    	if not affilated_union_id then return end  
    	local affilated_union_id_t = affilated_union_id 
    	UIRoleForcesMain.remove_self()     
        UnionUIJudge.create(affilated_union_id_t)
    end
end

local function deal_with_send_mail(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		SendMailUI.create("","",user_id,user_name)
	end
end


-- 玩家信息
local function setUserInfo( user_name_t,user_renown_t,user_renown_max_t,region_id)
	user_renown = user_renown_t
	user_name = user_name_t
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	local label_user_name = uiUtil.getConvertChildByName(img_labels,"label_user_name")
	label_user_name:setText(user_name)
	local label_renown = uiUtil.getConvertChildByName(img_labels,"label_renown")
	-- if user_renown_max_t then 
	-- 	label_renown:setText(user_renown .. "/" .. user_renown_max_t)
	-- else
	-- 	label_renown:setText(user_renown)
	-- end
	label_renown:setText(userData.getUserForcesPower())

	local label_user_help_id = uiUtil.getConvertChildByName(img_labels,"label_user_help_id")

	label_user_help_id:setText(userData.getUserHelpId())


	local label_region = uiUtil.getConvertChildByName(img_labels,"label_region")
	local region_name = languagePack["region_border"]
	local region_state = userData.getBornRegion()
    local region_info = Tb_cfg_region[region_state] 
    if region_state and region_info then 
        regionName = region_info.name 
    end
    label_region:setText(regionName)

end

-- 同盟信息
local function setUnionVisible(visibleUnion,visibleAffilatedUnion)
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	local label_affiliated_union = uiUtil.getConvertChildByName(instance,"label_affiliated_union")
	local btn_affiliated_union = uiUtil.getConvertChildByName(instance,"btn_affiliated_union")
	label_affiliated_union:setVisible(visibleAffilatedUnion)
	btn_affiliated_union:setVisible(visibleAffilatedUnion)
	btn_affiliated_union:setTouchEnabled(visibleAffilatedUnion)

	local btn_union = uiUtil.getConvertChildByName(instance,"btn_union_0")
	local label_union = uiUtil.getConvertChildByName(img_labels,"label_union")
	local label_union_position = uiUtil.getConvertChildByName(img_labels,"label_union_position")
	local label_union_null = uiUtil.getConvertChildByName(img_labels,"label_union_null")

	btn_union:setVisible(visibleUnion)
	btn_union:setTouchEnabled(visibleUnion)
	label_union:setVisible(true)
	label_union_position:setVisible(visibleUnion)
	label_union_null:setVisible(not visibleUnion)

end

local function setUnionInfo(union_id_t,affilated_union_id_t)
	union_id = tonumber(union_id_t)
	affilated_union_id = tonumber(affilated_union_id_t)

	local visibleUnion,visibleAffilatedUnion = false,false
	if affilated_union_id and affilated_union_id ~= 0 then 
		visibleAffilatedUnion = true
	end

	if union_id and union_id ~= 0 then 
		visibleUnion = true
	end
	setUnionVisible(visibleUnion,visibleAffilatedUnion)
end

local function setUnionLabels(union_name,affilated_union_name,position)
	union_position = position
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	local label_union_position = uiUtil.getConvertChildByName(img_labels,"label_union_position")
	if positionType[position] then 
		label_union_position:setText(positionType[position])
	elseif position == 0 then 
		label_union_position:setText(languagePack["chengyuan"])
	end

	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	local btn_union = uiUtil.getConvertChildByName(instance,"btn_union_0")
	btn_union:setTitleText(union_name)
	local btn_affiliated_union = uiUtil.getConvertChildByName(instance,"btn_affiliated_union")
	btn_affiliated_union:setTitleText(affilated_union_name)

	
	local visibleUnion,visibleAffilatedUnion = true,true
	if union_name == "" then  
		visibleUnion = false
	end
	if affilated_union_name == "" then 
		visibleAffilatedUnion = false
	end
	setUnionVisible(visibleUnion,visibleAffilatedUnion)

	if union_name ~= "" and (position == 1 or position == 2 ) then 
		isRangerAble = false
	else
		isRangerAble = true
	end
end


-- 个人介绍
local function setIntroduction(introduction)
	-- 个人签名
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	local label_introduction = uiUtil.getConvertChildByName(img_labels,"label_introduction")
	label_introduction:setText(introduction)

	local label_intro_none = uiUtil.getConvertChildByName(instance,"label_intro_none")
	if StringUtil.isEmptyStr(introduction) then  
		label_intro_none:setVisible(true)
	else
		label_intro_none:setVisible(false)
	end
end

-- 部队信息
local function setArmyInfo()
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	-- 武将卡数
	local total_card = 0
	local total_card_max = sysUserConfigData.get_card_bag_nums()
	for k,v in pairs(heroData.getAllHero()) do 
		if v.userid == user_id then 
			total_card = total_card + 1
		end
	end
	
	-- 部队数 和 总兵力
	local total_army = 0
	local total_army_max = getTotalArmyMax()
	local total_soldier = 0 
	for k,v in pairs(armyData.getAllTeamMsg()) do 
		total_army = total_army + 1
		total_soldier = total_soldier + armyData.getTeamHp(k)
	end
	
	-- 武将卡数
	if total_card > 0 then 
		local label_total_card = uiUtil.getConvertChildByName(img_labels,"label_total_card")
		label_total_card:setText(total_card .. "/" .. total_card_max)
	end

	-- 总部队数
	if total_army > 0 then 
		local label_total_army = uiUtil.getConvertChildByName(img_labels,"label_total_army")
		label_total_army:setText(total_army .. "/" .. total_army_max)
	end

	-- 总兵力数
	if total_soldier > 0 then 
		local label_total_soldier = uiUtil.getConvertChildByName(img_labels,"label_total_soldier")
		label_total_soldier:setText(total_soldier)
	end
end

-- 领地 分城等信息
local function setCityInfo(total_manor,total_town,total_fort,total_city,total_city_max)
	-- 总领地数
	local total_manor_max = math.floor(user_renown/100)
	-- 总分城数
	local total_town_max = get_town_max(user_renown)
	-- 总要塞数
	total_fort_max = get_fort_max(user_renown)


	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	-- 总领地数
	if total_manor > 0 then 
		local label_total_manor = uiUtil.getConvertChildByName(img_labels,"label_total_manor")
		label_total_manor:setText(total_manor .. "/" .. total_manor_max)
	end
	-- 总分城数
	if total_town > 0 then 
		local label_total_town = uiUtil.getConvertChildByName(img_labels,"label_total_town")
		label_total_town:setText(total_town .. "/" .. total_town_max)
	end
	-- 总要塞数
	if total_fort > 0 then 
		local label_total_fort = uiUtil.getConvertChildByName(img_labels,"label_total_fort")
		label_total_fort:setText(total_fort .. "/" .. total_fort_max)
	end
	-- 城市总面积
	if total_city > 0 then 
		-- local label_total_city = uiUtil.getConvertChildByName(img_labels,"label_total_city")
		-- label_total_city:setText(total_city .. "/" .. total_city_max)
	end
end

local function setResInfo(res_wood,res_stone,res_iron,res_food,daily_coin)
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")

	if res_wood> 0 then 
		local label_res_wood = uiUtil.getConvertChildByName(img_labels,"label_res_wood")
		label_res_wood:setText(res_wood)
	end
	if res_stone> 0 then 
		local label_res_stone = uiUtil.getConvertChildByName(img_labels,"label_res_stone")
		label_res_stone:setText(res_stone)
	end
	if res_iron> 0 then 
		local label_res_iron = uiUtil.getConvertChildByName(img_labels,"label_res_iron")
		label_res_iron:setText(res_iron)
	end
	if res_food> 0 then 
		local label_res_food = uiUtil.getConvertChildByName(img_labels,"label_res_food")
		label_res_food:setText(res_food)
	end
	if daily_coin> 0 then 
		local label_daily_coin = uiUtil.getConvertChildByName(img_labels,"label_daily_coin")
		label_daily_coin:setText(daily_coin)
	end
end

local function setOwnVisible()

	--申请好友相关
	local btn_other_friend = uiUtil.getConvertChildByName(instance,"btn_other_friend")
	btn_other_friend:setVisible(not is_own)
	btn_other_friend:setTouchEnabled(not is_own)
	--发送邮件相关
	local btn_other_mail = uiUtil.getConvertChildByName(instance,"btn_other_mail")
	btn_other_mail:setVisible(not is_own)
	btn_other_mail:setTouchEnabled(not is_own)



	--排行榜相关
	local btn_rank = uiUtil.getConvertChildByName(instance,"btn_rank")
	btn_rank:setVisible(is_own)
	btn_rank:setTouchEnabled(is_own)
	btn_rank:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("game/ranking/rankingManager")
            rankingManager.on_enter()
        end
	end)
	--修改个人介绍
	local btn_modify_signature = uiUtil.getConvertChildByName(instance,"btn_modify_signature")
	btn_modify_signature:setVisible(is_own)
	btn_modify_signature:setTouchEnabled(is_own)

end

function UIRoleForcesBase.updateSelfView()
	setUserInfo(userData.getRoleName(),userData.getShowRenownNums(),userData.getShowRenownNumsMax())
	setUnionInfo(userData.getUnion_id(), userData.getAffilated_union_id())
	setIntroduction(userData.getUserIntroduction())
	setArmyInfo()

	local total_city,total_city_max = get_city_area()
	setCityInfo(
		#get_manor_list(user_id), 
		userCityData.getHaveNumsByType(cityTypeDefine.fencheng),
		userCityData.getHaveNumsByType(cityTypeDefine.yaosai),
		total_city,total_city_max
		)

	local selfCommonRes = politics.getSelfRes()
	setResInfo(
		selfCommonRes.wood_add,
		selfCommonRes.stone_add,
		selfCommonRes.iron_add,
		selfCommonRes.food_add - selfCommonRes.food_cost ,
		selfCommonRes.login_money
		)
	setOwnVisible()
end

function UIRoleForcesBase.updateOthersView()
	-- 设置布局的可视化 等待服务端数据
	setOwnVisible()
end

function UIRoleForcesBase.updateData()
	if is_own then 
		UIRoleForcesBase.updateSelfView()
	else
		UIRoleForcesBase.updateOthersView()
	end
	UIRoleForcesBase.receiveDataFromServer(detail_info_from_server)
end

function UIRoleForcesBase.receiveDataFromServer(packet)
	if not packet then return end
	netObserver.removeObserver(GET_USER_PROFILE)
	
	instance:setVisible(true)
	detail_info_from_server = packet
	

	if (user_id == userData.getUserId()) then 
		setUserInfo(packet[6],packet[7])
		setUnionInfo(userData.getUnion_id(), userData.getAffilated_union_id())
		-- 自己的
		local position = 0
        if allTableData[dbTableDesList.user_union_attr.name] and 
            allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()]
            then

            position = allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()].official_id
        end
        
		setUnionLabels(packet[1],packet[2],position)
	else
		setUserInfo(packet[6],math.floor(packet[7] / 100))
		setUnionInfo(packet[3],packet[4])
		setUnionLabels(packet[1],packet[2],packet[5])
		setIntroduction(packet[8])
		setCityInfo( packet[9],packet[10],packet[11],packet[12],packet[13])
	end
end



function UIRoleForcesBase.create(parent,user_id_t)
	if instance then return end
	instance = GUIReader:shareReader():widgetFromJsonFile("test/role_forces_base.json")
	-- instance:setScale(config.getgScale())
	parent:addChild(instance)
	instance:setVisible(false)
	
	user_id = user_id_t
	if not user_id then 
		user_id = userData.getUserId()
	end

	if user_id == userData.getUserId() then 
		is_own = true
	else
		is_own = false
	end
	
	UIRoleForcesBase.updateData()


	--修改签名按钮事件
	local function clickEditIntro(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			UIRoleForcesEditIntro.show(user_id)
		end
	end

	local btn_modify_signature = uiUtil.getConvertChildByName(instance,"btn_modify_signature")
	btn_modify_signature:setTouchEnabled(true)
	btn_modify_signature:addTouchEventListener(clickEditIntro)

	-- 同盟按钮事件
	local btn_union = uiUtil.getConvertChildByName(instance,"btn_union_0")
	btn_union:setTouchEnabled(true)
	btn_union:addTouchEventListener(deal_with_jump_union)

	local btn_affiliated_union = uiUtil.getConvertChildByName(instance,"btn_affiliated_union")
	btn_affiliated_union:addTouchEventListener(deal_with_jump_affilated_union)

	-- 发送邮件事件
	local btn_other_mail = uiUtil.getConvertChildByName(instance,"btn_other_mail")
	btn_other_mail:addTouchEventListener(deal_with_send_mail)


	netObserver.addObserver(GET_USER_PROFILE, UIRoleForcesBase.receiveDataFromServer)
	Net.send(GET_USER_PROFILE, {user_id})
end

return UIRoleForcesBase
