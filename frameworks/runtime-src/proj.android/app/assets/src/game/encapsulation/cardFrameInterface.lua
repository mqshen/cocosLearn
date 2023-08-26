--[[
卡片相关信息
卡牌边框/星数： quality(稀有度) 稀有度：1:C,2:UC,3:R,4:SR,5:UR
Gray_card_box.png			Green_card_box.png			blue_card_box.png			Purple_card_box.png
Gray_card_box_zhong.png		Green_card_box_zhong.png	blue_card_box_zhong.png		Purple_card_box_zhong.png
没有边框

国家1:汉,2:魏,3:蜀,4:吴,5:群
newhan.png newwei.png newshu.png newwu.png newqun.png
han_big.png 	wei_big.png 	shu_big.png 	wu_big.png 	qun_big.png
han_big.png 	wei_big.png 	shu_big.png 	wu_big.png 	qun_big.png

兵种 1：弓兵,2：枪兵,3：骑兵
Arrow_Icon.png 	Spearman_Icon.png 	cavalry_Icon.png
--]]

--[[
--判断文件是否存在
local function icon_img_exist(hero_id)
	local relative_icon_path = "gameResources/card/card_" .. hero_id .. ".png"
	local absolute_icon_path = CCFileUtils:sharedFileUtils():fullPathForFilename(relative_icon_path)
	local file = io.open(absolute_icon_path, "rb")
	if file then
		file:close()
		return true
	else
		return false
	end
end

local function find_hero_id_for_no_img()
	print("缺省图标的卡片ID列表：")
	local exist_nums = 0
	local unexist_nums = 0
	local unexist_id_list = {}
	for k,v in pairs(Tb_cfg_hero) do
	 	if icon_img_exist(k) then
	 		exist_nums = exist_nums + 1
	 	else
	 		unexist_nums = unexist_nums + 1
	 		table.insert(unexist_id_list, k)
	 	end
	 end

	 table.sort(unexist_id_list)
	 print("存在图标 " .. exist_nums)
	 print("不存在个数 " .. unexist_nums)
	 for k,v in pairs(unexist_id_list) do
	 	print(v)
	 end
end
--]]

local uiUtil = require("game/utils/ui_util")
local m_show_type = nil
local m_hero_id = nil
local m_parent_panel = nil



------------------ 初始化一些状态
local function initFrameWidgetDefault(temp_widget)
	if not temp_widget then return end

	local panel_card_frame = uiUtil.getConvertChildByName(temp_widget,"panel_card_frame")
	local panel_advance_info = uiUtil.getConvertChildByName(temp_widget,"panel_advance_info")

	panel_card_frame:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_advance_info:setBackGroundColorType(LAYOUT_COLOR_NONE)

	panel_advance_info:setVisible(false)

	local img_flag_left_point = uiUtil.getConvertChildByName(temp_widget,"img_flag_left_point")
	img_flag_left_point:setVisible(false)
	local img_max_advanced = uiUtil.getConvertChildByName(panel_advance_info,"img_max_advanced")
	local img_flag = uiUtil.getConvertChildByName(img_max_advanced,"img_flag")
	img_flag:setVisible(false)
end


---  由于剩余点数 红点标志和 极 字 同一个区域 所以适配下位置
local function checkRedPointFlag(temp_widget)
	if not temp_widget then return end
	local img_flag_left_point = uiUtil.getConvertChildByName(temp_widget,"img_flag_left_point")
	local panel_advance_info = uiUtil.getConvertChildByName(temp_widget,"panel_advance_info")
	local img_max_advanced = uiUtil.getConvertChildByName(panel_advance_info,"img_max_advanced")
	local img_flag = uiUtil.getConvertChildByName(img_max_advanced,"img_flag")
	img_flag:setVisible(false)
	if img_flag_left_point:isVisible() and img_max_advanced:isVisible() then 
		img_flag_left_point:setVisible(false)
		img_flag:setVisible(true)
	end





end


--- 极字特效
local function showAdvacedMaxEffect(temp_widget)
	if not temp_widget then return end
	local panel_advance_info = uiUtil.getConvertChildByName(temp_widget,"panel_advance_info")
	local img_max_advanced = uiUtil.getConvertChildByName(panel_advance_info,"img_max_advanced")
	local panel_effect = uiUtil.getConvertChildByName(img_max_advanced,"panel_effect")

	if img_max_advanced:isVisible()  then 
		panel_effect:removeAllChildrenWithCleanup(true)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jizi_texiao.ExportJson")
        local effectAnimation = CCArmature:create("jizi_texiao")
        effectAnimation:getAnimation():playWithIndex(0)
        -- effectAnimation:getAnimation():setSpeedScale(effectAnimation:getAnimation():getSpeedScale()/2)
        effectAnimation:ignoreAnchorPointForPosition(false)
        effectAnimation:setAnchorPoint(cc.p(0.5, 0.5))
        panel_effect:addChild(effectAnimation)
        effectAnimation:setPosition(cc.p(panel_effect:getContentSize().width/2,panel_effect:getContentSize().height/2 + 3 ))
        effectAnimation:setName("effectAnimation_jizi_texiao")
        effectAnimation:setZOrder(999)
        panel_effect:setVisible(true)
	else
		panel_effect:setVisible(false)
	end

end

local function playArmatureOnce(file,parent,posx,posy,apx,apy,scale,callback)
    if not parent then return end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/" .. file .. ".ExportJson")
    local armature = CCArmature:create(file)
    if apx and apy then 
    	armature:setAnchorPoint(cc.p(apx,apy))
    end
    if not scale then scale = 1 end
    armature:getAnimation():playWithIndex(0)
    parent:addChild(armature,999,999)
    armature:setPosition(cc.p(posx , posy))
    armature:setScale(scale)
    loadingLayer.create(nil,false)
    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 or eventType == 2 then
            armatureNode:removeFromParentAndCleanup(true)
            armature = nil
            loadingLayer.remove()
            CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/" .. file .. ".ExportJson")
			if callback then callback() end
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
end


-- 进阶星星特效
local function showAdvancedStarEffect(temp_widget,cur_quality_lv,max_quality_lv,callback)
	if not temp_widget then return end
	
	
	local start_indx = 5 - max_quality_lv

	local panel_advance_info = uiUtil.getConvertChildByName(temp_widget,"panel_advance_info")
	local img_star = nil
	img_star = uiUtil.getConvertChildByName(panel_advance_info,"img_star_" .. start_indx + cur_quality_lv)

	if img_star then
		playArmatureOnce("jingjie_xingxing",img_star,-2,-4,0.5,0.5,nil,callback)
	else
		if callback then
			callback()
		end
	end
end
----------- cur_quality  		当前进阶数
----------- max_quality  		最大进阶数
----------- isSkillLearnedMax	技能是否学满（极）
local function doSetAdvancedDetail(temp_widget,cur_quality,max_quality,isSkillLearnedMax)
	if not temp_widget then return end

	local panel_advance_info = uiUtil.getConvertChildByName(temp_widget,"panel_advance_info")
	panel_advance_info:setVisible(true)
	panel_advance_info:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local img_max_advanced = uiUtil.getConvertChildByName(panel_advance_info,"img_max_advanced")
	img_max_advanced:setVisible(isSkillLearnedMax)

	--- 极字特效
	local panel_effect = uiUtil.getConvertChildByName(img_max_advanced,"panel_effect")
	panel_effect:setBackGroundColorType(LAYOUT_COLOR_NONE)
	
	
	panel_effect:setVisible(false)



	local img_flag = uiUtil.getConvertChildByName(img_max_advanced,"img_flag")
	img_flag:setVisible(false)

	local img_star = nil
	local tmp_indx = {5,4,3,2,1}
	for i = 5,1,-1 do 
		img_star = uiUtil.getConvertChildByName(panel_advance_info,"img_star_" .. i)
		
		if tmp_indx[i] <= max_quality then 
			img_star:setVisible(true)
		else
			img_star:setVisible(false)
		end


		-- if img_star:isVisible() then 
		-- 	if i <= cur_quality then 
		-- 		img_star:loadTexture(ResDefineUtil.ui_card_star[2],UI_TEX_TYPE_PLIST)
		-- 	else
		-- 		img_star:loadTexture(ResDefineUtil.ui_card_star[3],UI_TEX_TYPE_PLIST)
		-- 	end
		-- end

	end
	local star_indx = 1
	for i = 1,5 do 
		img_star = uiUtil.getConvertChildByName(panel_advance_info,"img_star_" .. i)
		if img_star:isVisible() then 
			star_indx = i
			break
		end
	end
	for i = 1 ,5 do 
		img_star = uiUtil.getConvertChildByName(panel_advance_info,"img_star_" .. i)
		if i - star_indx + 1 <= cur_quality then 
			img_star:loadTexture(ResDefineUtil.ui_card_star[2],UI_TEX_TYPE_PLIST)
		else
			img_star:loadTexture(ResDefineUtil.ui_card_star[3],UI_TEX_TYPE_PLIST)
		end
	end

	checkRedPointFlag(temp_widget)
end
--- 进阶信息
local function setAdvancedDetail(temp_widget,hero_uid,hero_id)
	if not temp_widget then return end

	local base_hero_info = Tb_cfg_hero[hero_id]
	local hero_info = heroData.getHeroInfo(hero_uid)

	local cur_quality_lv = 0
	local max_quality_lv = base_hero_info.quality + 1

	local skillLearnedNum = 0
	if hero_info then 
		cur_quality_lv = hero_info.advance_num
		local hero_skill_list = heroData.getHeroSkillList(hero_info.heroid_u)  or {}
		skillLearnedNum = #hero_skill_list
	end
	doSetAdvancedDetail(temp_widget,cur_quality_lv,max_quality_lv,skillLearnedNum >= 3)
end


--[==[
--判断文件是否存在
local function icon_img_exist(show_type, hero_id)
	local new_file_name = CCFileUtils:sharedFileUtils():getWritablePath() .. "card_" .. hero_id .. "_" .. show_type .. ".png"
	--local absolute_icon_path = CCFileUtils:sharedFileUtils():fullPathForFilename(relative_icon_path)
	local file = io.open(new_file_name, "rb")
	if file then
		file:close()
		return true
	else
		return false
	end
end

local function test_icon_img(show_type, hero_id)
	if show_type ~= 2 and show_type ~= 3 then
		return
	end

	if icon_img_exist(show_type, hero_id) then
		MainScreenNotification.create("haha >>>>>>>>>>>>>>>>>>>>>>>> ")
	else
		MainScreenNotification.create("wocao <<<<<<<<<<<<<<<<<<<<<< ")

		local res_img_name = "gameResources/card/card_" .. hero_id .. ".png"
		local icon_img = ImageView:create()
		icon_img:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)

		local temp_width, temp_height = 0, 0
		if show_type == 2 then
			if Tb_cfg_hero_rect[hero_id] then
				icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][2][1], Tb_cfg_hero_rect[hero_id][2][2], Tb_cfg_hero_rect[hero_id][2][3], Tb_cfg_hero_rect[hero_id][2][4]))
				--temp_width = Tb_cfg_hero_rect[hero_id][2][3]
				--temp_height = Tb_cfg_hero_rect[hero_id][2][4]
				icon_img:setScale(Tb_cfg_hero_rect[hero_id][2][5])
			else
				icon_img:setTextureRect(CCRectMake(0,0,140,192))
				--temp_width = 140
				--temp_height = 192
			end

			temp_width = 140
			temp_height = 192
		elseif show_type == 3 then
			if Tb_cfg_hero_rect[hero_id] then
				icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][1][1], Tb_cfg_hero_rect[hero_id][1][2], Tb_cfg_hero_rect[hero_id][1][3], Tb_cfg_hero_rect[hero_id][1][4]))
				--temp_width = Tb_cfg_hero_rect[hero_id][1][3]
				--temp_height = Tb_cfg_hero_rect[hero_id][1][4]
				icon_img:setScale(Tb_cfg_hero_rect[hero_id][1][5])
			else
				icon_img:setTextureRect(CCRectMake(0,0,210,70))
				--temp_width = 210
				--temp_height = 70
			end

			temp_width = 210
			temp_height = 70
		end

		print("===============" .. temp_width .. "/" .. temp_height)
		icon_img:setAnchorPoint(cc.p(0, 0))

		---[[
		if temp_width ~= 0 and temp_height ~= 0 then
			local temp_render_texture = CCRenderTexture:create(temp_width, temp_height, kCCTexture2DPixelFormat_RGBA8888)
			temp_render_texture:begin()
			icon_img:visit()
			temp_render_texture:endToLua()
			local temp_file_name = "test_" .. show_type .. "_" .. hero_id .. ".png"
			temp_render_texture:saveToFile(temp_file_name, kCCImageFormatPNG)
		end
		--]]
	end
end

local function reload_icon_after_download(show_type, hero_id, parent_panel)
	local res_img_name = nil

	local icon_img = ImageView:create()
	if show_type == 1 then 		----背景框宽度280、头像宽度350
		res_img_name = "gameResources/card/card_" .. hero_id .. ".png"
		icon_img:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)
		icon_img:setScale(0.8)
	else
		if icon_img_exist(show_type, hero_id) then
			res_img_name = CCFileUtils:sharedFileUtils():getWritablePath() .. "card_" .. hero_id .. "_" .. show_type .. ".png"
			icon_img:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)
		else
			local show_width, show_height = nil, nil
			res_img_name = "gameResources/card/card_" .. hero_id .. ".png"
			icon_img:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)

			if show_type == 2 then
				if Tb_cfg_hero_rect[hero_id] then
					icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][2][1], Tb_cfg_hero_rect[hero_id][2][2], Tb_cfg_hero_rect[hero_id][2][3], Tb_cfg_hero_rect[hero_id][2][4]))
					icon_img:setScale(Tb_cfg_hero_rect[hero_id][2][5])
				else
					icon_img:setTextureRect(CCRectMake(0,0,140,192))
				end
				show_width = 140
				show_height = 192
			elseif show_type == 3 then
				if Tb_cfg_hero_rect[hero_id] then
					icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][1][1], Tb_cfg_hero_rect[hero_id][1][2], Tb_cfg_hero_rect[hero_id][1][3], Tb_cfg_hero_rect[hero_id][1][4]))
					icon_img:setScale(Tb_cfg_hero_rect[hero_id][1][5])
				else
					icon_img:setTextureRect(CCRectMake(0,0,210,70))
				end
				show_width = 210
				show_height = 70
			end

			icon_img:setAnchorPoint(cc.p(0, 0))
			local temp_render_texture = CCRenderTexture:create(show_width, show_height, kCCTexture2DPixelFormat_RGBA8888)
			temp_render_texture:begin()
			icon_img:visit()
			temp_render_texture:endToLua()
			local new_file_name = "card_" .. hero_id .. "_"  .. show_type .. ".png"
			temp_render_texture:saveToFile(new_file_name, kCCImageFormatPNG)
			icon_img:setAnchorPoint(cc.p(0.5, 0.5))
		end
	end

	cardTextureManager.add_new_card_file(res_img_name)
	icon_img:setPosition(cc.p(parent_panel:getContentSize().width/2, parent_panel:getContentSize().height/2))
	parent_panel:addChild(icon_img, -1, 1)

	return icon_img
end
--]==]
---[[
local function reload_icon_after_download(show_type, hero_id, parent_panel)
	local icon_img = ImageView:create()
	-- if config.getCardDrawById(hero_id) and show_type ~= 1 then
	-- 	local rect_img_name = nil
	-- 	if show_type == 2 then
	-- 		rect_img_name = "gameResources/middleCard/card_" .. hero_id .. ".png"
	-- 	elseif show_type == 3 then
	-- 		rect_img_name = "gameResources/smallCard/card_" .. hero_id .. ".png"
	-- 	end
	-- 	icon_img:loadTexture(rect_img_name, UI_TEX_TYPE_LOCAL)
	-- 	cardTextureManager.add_new_card_file(rect_img_name)
	-- else
		local res_img_name = "gameResources/card/card_" .. hero_id .. ".png"
		icon_img:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)
		cardTextureManager.add_new_card_file(res_img_name)
		-- if show_type == 2 then
		-- 	icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][2][1], Tb_cfg_hero_rect[hero_id][2][2], Tb_cfg_hero_rect[hero_id][2][3], Tb_cfg_hero_rect[hero_id][2][4]))
		-- elseif show_type == 3 then
		-- 	icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][1][1], Tb_cfg_hero_rect[hero_id][1][2], Tb_cfg_hero_rect[hero_id][1][3], Tb_cfg_hero_rect[hero_id][1][4]))
		-- end
	-- end

	-- CardMgr:sharedCardMgr():drawCardTexture(tostring(hero_id), "gameResources/card/card_" .. hero_id .. ".png", 
	-- 	CCRectMake(Tb_cfg_hero_rect[hero_id][2][1], Tb_cfg_hero_rect[hero_id][2][2], Tb_cfg_hero_rect[hero_id][2][3], Tb_cfg_hero_rect[hero_id][2][4]), 
	-- 	CCRectMake(Tb_cfg_hero_rect[hero_id][1][1], Tb_cfg_hero_rect[hero_id][1][2], Tb_cfg_hero_rect[hero_id][1][3], Tb_cfg_hero_rect[hero_id][1][4]))

	if show_type == 1 then
		icon_img:setScale(1)	--背景框宽度480、头像宽度350
	elseif show_type == 2 then
		if Tb_cfg_hero_rect[hero_id] then
			icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][2][1], Tb_cfg_hero_rect[hero_id][2][2], Tb_cfg_hero_rect[hero_id][2][3], Tb_cfg_hero_rect[hero_id][2][4]))
			icon_img:setScale(Tb_cfg_hero_rect[hero_id][2][5])
		else
			icon_img:setTextureRect(CCRectMake(0,0,140,192))
		end
	elseif show_type == 3 then
		if Tb_cfg_hero_rect[hero_id] then
			icon_img:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][1][1], Tb_cfg_hero_rect[hero_id][1][2], Tb_cfg_hero_rect[hero_id][1][3], Tb_cfg_hero_rect[hero_id][1][4]))
			icon_img:setScale(Tb_cfg_hero_rect[hero_id][1][5])
		else
			icon_img:setTextureRect(CCRectMake(0,0,210,70))
		end
	end
	icon_img:setPosition(cc.p(parent_panel:getContentSize().width/2, parent_panel:getContentSize().height/2))
	parent_panel:addChild(icon_img,-1,1)

	return icon_img
end
--]]




local function create_icon_img(show_type, hero_id, parent_panel)
	-- if not CCUpdate:sharedUpdate():downLoadRes(tostring(hero_id)) then
	-- 	return reload_icon_after_download(show_type, hero_id, parent_panel)
	-- else
	-- 	loadingLayer.create("nil")
	-- 	CCUpdate:sharedUpdate():registerScriptHandlerByName(tostring(hero_id), function ( endtype)
	-- 		if endtype == 1 then
	-- 			loadingLayer.remove()
	-- 		end
			return reload_icon_after_download(show_type, hero_id, parent_panel)
	-- 	end)
	-- end
end

local function create_frame_image(show_type, hero_quality, parent_panel)
	local card_frame_res = nil
	if show_type == 1 then
		card_frame_res = ResDefineUtil.ui_card_frame_big
	elseif show_type == 2 then
		card_frame_res = ResDefineUtil.ui_card_frame_middle
	elseif show_type == 3 then
		card_frame_res = ResDefineUtil.ui_card_frame_small
		hero_quality = 1
	end
	
	local frame_img = ImageView:create()
	frame_img:loadTexture(card_frame_res[hero_quality], UI_TEX_TYPE_PLIST)
	frame_img:setScale9Enabled(true)
	frame_img:setSize(CCSizeMake(card_frame_res[99][1], card_frame_res[99][2]))
	frame_img:setCapInsets(CCRectMake(card_frame_res[99][3], card_frame_res[99][4],card_frame_res[99][5], card_frame_res[99][6]))
	frame_img:setPosition(cc.p(parent_panel:getContentSize().width/2, parent_panel:getContentSize().height/2))
	if show_type == 3 then
		parent_panel:addChild(frame_img, -2)
	else
		parent_panel:addChild(frame_img, 1)
	end
end



-- local function set_star_img(temp_widget,show_type, hero_quality,hero_info)
-- 	local parent_panel = nil
-- 	if show_type == 3 then 
-- 		parent_panel = tolua.cast(temp_widget:getChildByName("other_img_panel"), "Layout")
-- 	else
-- 		parent_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
-- 	end
	
-- 	local start_x, start_y = 0, 0
-- 	local scale_value = 1
-- 	local split_width = 14
-- 	if show_type == 1 then
-- 		start_x = 300
-- 		start_y = 460
-- 		scale_value = 1
-- 		split_width = 30
-- 	elseif show_type == 2 then
-- 		start_x = 125
-- 		start_y = 185
-- 		scale_value = 0.6
-- 		split_width = 14
-- 	elseif show_type == 3 then
-- 		start_x = 133
-- 		start_y = 65
-- 		scale_value = 0.4
-- 		split_width = 12
-- 	end

-- 	local cur_quality_lv = 0
-- 	local max_quality_lv = hero_quality + 1

-- 	if hero_info then 
-- 		cur_quality_lv = hero_info.advance_num
-- 	end

-- 	for i=1,hero_quality + 1 do
-- 		local star_img = nil
-- 		star_img = uiUtil.getConvertChildByName(parent_panel,"star_img_" .. i)
-- 		if not star_img then 
-- 			star_img = ImageView:create()
-- 		end
		
-- 		star_img:setPosition(cc.p(start_x - (i-1)*split_width, start_y))
-- 		parent_panel:addChild(star_img)
-- 		if (max_quality_lv - i) < cur_quality_lv then 
-- 			star_img:loadTexture(ResDefineUtil.ui_card_star[2], UI_TEX_TYPE_PLIST)
-- 		else
-- 			star_img:loadTexture(ResDefineUtil.ui_card_star[3], UI_TEX_TYPE_PLIST)
-- 		end
-- 		star_img:setScale(scale_value)
-- 	end
	

-- end

local function create_country_img(show_type, country_type, parent_panel)
	local country_img = ImageView:create()
	if show_type == 1 or show_type == 2 then
		country_img:loadTexture(ResDefineUtil.ui_card_country[country_type], UI_TEX_TYPE_PLIST)
		if show_type == 1 then
			country_img:setPosition(cc.p(26,460))
		else
			country_img:setScale(0.75)
			country_img:setPosition(cc.p(18,179))
		end
		country_img:setZOrder(999)
	else
		country_img:loadTexture(ResDefineUtil.small_card_country[country_type], UI_TEX_TYPE_PLIST)
		country_img:setPosition(cc.p(country_img:getContentSize().width/2 - 2, 65))
	end
	
	parent_panel:addChild(country_img)
end

local function create_type_img(show_type, hero_type, parent_panel)
	local card_type_res = ResDefineUtil.img_soldier_type
	local type_img = ImageView:create()
	type_img:loadTexture(card_type_res[hero_type], UI_TEX_TYPE_PLIST)
	type_img:setZOrder(300)
	if show_type == 1 then
		type_img:setScale(0.8)
		type_img:setPosition(cc.p(290,19))
	elseif show_type == 2 then
		type_img:setScale(0.6)
		type_img:setPosition(cc.p(124,13))
	elseif show_type == 3 then
		type_img:setScale(0.8)
		type_img:setPosition(cc.p(120,13))
	end
	
	parent_panel:addChild(type_img)
end

local function set_lv_images(level,temp_widget)
	local atlas_label_lv = uiUtil.getConvertChildByName(temp_widget,"atlas_label_lv")
	atlas_label_lv:setStringValue(level)
end

--需要手动设置卡牌显示的兵数
--beforeCount 现在带兵数量
--afterCount 战后带兵数量(一般是缺省，战报的时候用到)
local function set_army_count(temp_widget, beforeCount, afterCount )
	if tolua.cast(temp_widget:getChildByName("num_label"),"Label") then
		tolua.cast(temp_widget:getChildByName("num_label"),"Label"):setText(beforeCount)
	end
	if afterCount and tolua.cast(temp_widget:getChildByName("armyleft_label"),"Label") then
    	tolua.cast(temp_widget:getChildByName("armyleft_label"),"Label"):setText(afterCount)
    	tolua.cast(temp_widget:getChildByName("armyleft_label"),"Label"):setVisible(true)
    end
end

local function set_cost_imgs(hero_id,temp_widget,show_type)
	local basic_hero_info = Tb_cfg_hero[hero_id]


	local atlas_label_cost = uiUtil.getConvertChildByName(temp_widget,"atlas_label_cost")
	local cost = basic_hero_info.cost
	cost = cost/10

	atlas_label_cost:setStringValue(cost)
end

local function get_hp_txt(temp_widget, show_type)
	if show_type == 1 or show_type == 2 then
		return tolua.cast(temp_widget:getChildByName("num_label"), "Label")
	else
		return nil
	end
end

local function set_show_content_info(show_type, hero_uid, hero_id, is_need_event, temp_widget)
	local hero_info = heroData.getHeroInfo(hero_uid)
	local base_hero_info = Tb_cfg_hero[hero_id]
	local level = nil
	if hero_info then
		level = hero_info.level
	else
		level = 1
	end
	if show_type == 1 or show_type == 2 then 
		local num_txt = tolua.cast(temp_widget:getChildByName("num_label"), "Label")
		local is_show_num, show_hp_num = true, 0
		if hero_info then
			if hero_info.armyid == 0 then
				is_show_num = false
			else
				local army_info = armyData.getTeamMsg(hero_info.armyid)
				if army_info and army_info.counsellor_heroid_u == hero_uid then
					is_show_num = false
				else
					show_hp_num = hero_info.hp
				end
			end
		else
			is_show_num = false
		end

		if is_show_num then
			if show_type == 1 then
				num_txt:setText(show_hp_num)
			else
				if show_hp_num < 1000 then
					num_txt:setFontSize(14)
				else
					num_txt:setFontSize(12)
				end
				num_txt:setText(show_hp_num)
			end
		else
			if show_type == 2 then
				num_txt:setFontSize(14)
			end
			num_txt:setText("--")
		end

		set_cost_imgs(hero_id,temp_widget,show_type)
	end

	set_lv_images(level,temp_widget)

	local atlas_label_attack_range = uiUtil.getConvertChildByName(temp_widget,"atlas_label_attack_range")
	atlas_label_attack_range:setStringValue(base_hero_info.hit_range)

	local name_txt = tolua.cast(temp_widget:getChildByName("name_label"), "Label")
	if string.len(base_hero_info.name) <= 4*3 then
		if show_type == 1 then
			name_txt:setFontSize(20)
			name_txt:setSize(CCSizeMake(18,145))
		elseif show_type == 2 then
			name_txt:setFontSize(16)
			name_txt:setSize(CCSizeMake(18,120))
		end
	else
		if show_type == 1 then
			name_txt:setFontSize(16)
			name_txt:setSize(CCSizeMake(18,110))
		elseif show_type == 2 then
			name_txt:setFontSize(12)
			name_txt:setSize(CCSizeMake(18,90))
		end
	end
	name_txt:setText(base_hero_info.name)
	if is_need_event then
		local function deal_with_card_click(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then
				if not uiManager.getLastMoveState() then
					-- cardDetailInfo.setShowId(hero_uid, hero_id)
					if hero_uid and hero_uid ~= 0 then 
						require("game/cardDisplay/userCardViewerLock")
						userCardViewerLock.create(nil,hero_uid)
					else
						require("game/cardDisplay/basicCardViewer")
						basicCardViewer.create(nil,hero_id)
					end
				end
			end
		end
		temp_widget:setTouchEnabled(true)
		temp_widget:addTouchEventListener(deal_with_card_click)
	end
end

-- 剩余可洗点数
local function set_left_point_info(temp_widget,left_point_num,hero_uid)
	local img_flag_left_point = uiUtil.getConvertChildByName(temp_widget,"img_flag_left_point")
	if not left_point_num then left_point_num = 0 end


	if left_point_num > 0 then 
		img_flag_left_point:setVisible(true)
	else
		img_flag_left_point:setVisible(false)
	end
	checkRedPointFlag(temp_widget)

	-- 进阶的红点又说不要了~~~~ 
	-- if img_flag_left_point:isVisible() then return end
	
	-- if not hero_uid then return end

	-- local hero_info = heroData.getHeroInfo(hero_uid)
	-- if not hero_info then return end
	-- -- 可进阶数
	-- local basicHeroInfo = Tb_cfg_hero[hero_info.heroid]
	-- if basicHeroInfo.quality >= HERO_ADVANCE_QUALITY_MIN then 
	-- 	if hero_info.advance_num < basicHeroInfo.quality + 1 then
	-- 		-- 可进阶了 看看有没有同名卡
	-- 		local heroInfo = nil
	-- 		for k,v in pairs(heroData.getAllHero()) do
	-- 			heroInfo = heroData.getHeroInfo(k)
	-- 			if hero_info.heroid == heroInfo.heroid and (hero_info.heroid_u ~= heroInfo.heroid_u) then 
	-- 				img_flag_left_point:setVisible(true)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

local function set_middle_touch_sign_related(temp_widget, is_need_touch_sign, deal_with_end_event)
	local selected_sign_img = nil
	if is_need_touch_sign then
		local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
		selected_sign_img = tolua.cast(bg_img_panel:getChildByName("touch_sign_img"), "ImageView")

		if not selected_sign_img then
			selected_sign_img = ImageView:create()
			selected_sign_img:setName("touch_sign_img")
			selected_sign_img:loadTexture(ResDefineUtil.ui_card_other_res[1], UI_TEX_TYPE_PLIST)
			selected_sign_img:setPosition(cc.p(bg_img_panel:getContentSize().width/2, bg_img_panel:getContentSize().height/2))
			selected_sign_img:setVisible(false)
			bg_img_panel:addChild(selected_sign_img)
		end
	end

	local show_state = false
	local function deal_with_card_touch(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if is_need_touch_sign and (not show_state) then
				selected_sign_img:setVisible(true)
				show_state = true
			end
		else
			if is_need_touch_sign and show_state then
				selected_sign_img:setVisible(false)
				show_state = false
			end

			if eventType == TOUCH_EVENT_ENDED and deal_with_end_event then
				deal_with_end_event(sender)
			end
		end
	end

	temp_widget:setTouchEnabled(true)
	temp_widget:addTouchEventListener(deal_with_card_touch)
end

local function set_big_card_info(temp_widget, hero_uid, hero_id, is_need_event,left_point_num)
	local hero_info = heroData.getHeroInfo(hero_uid)
	local base_hero_info = Tb_cfg_hero[hero_id]
	if not base_hero_info then
		return
	end

	local hero_quality = base_hero_info.quality

	local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	bg_img_panel:removeAllChildrenWithCleanup(true)
	--头像
	create_icon_img(1, hero_id, bg_img_panel)
	--边框背景
	create_frame_image(1, hero_quality, bg_img_panel)
	--星数
	-- set_star_img(temp_widget,1, hero_quality,hero_info)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	--国家
	create_country_img(1, base_hero_info.country, bg_img_panel)
	--兵种
	create_type_img(1, base_hero_info.hero_type, bg_img_panel)
	--显示信息
	set_show_content_info(1, hero_uid, hero_id, is_need_event, temp_widget)

	--技能剩余点数
	set_left_point_info(temp_widget,left_point_num)
	
end

local function create_big_card(hero_uid, hero_id, is_need_event,left_point_num)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameBig.json")
	set_big_card_info(temp_widget, hero_uid, hero_id, is_need_event,left_point_num)

	initFrameWidgetDefault(temp_widget)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	return temp_widget
end

local function reset_middle_card_info(temp_widget)
	local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	bg_img_panel:removeAllChildrenWithCleanup(true)
	local img_attention = tolua.cast(temp_widget:getChildByName("img_attention"),"ImageView")
	if img_attention then
		img_attention:setVisible(false)
	end
	temp_widget:setTouchEnabled(false)
end

local function set_middle_card_info(temp_widget, hero_uid, hero_id, left_point_num)
	local hero_info = heroData.getHeroInfo(hero_uid)
	local base_hero_info = Tb_cfg_hero[hero_id]
	if not base_hero_info then
		return
	end

	local hero_quality = base_hero_info.quality

	local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	bg_img_panel:removeAllChildrenWithCleanup(true)
	local img_attention = tolua.cast(temp_widget:getChildByName("img_attention"),"ImageView")
	if img_attention then
		img_attention:setVisible(false)
	end
	--头像
	create_icon_img(2, hero_id, bg_img_panel)
	--边框背景
	create_frame_image(2, hero_quality, bg_img_panel)
	--星数
	-- set_star_img(temp_widget,2, hero_quality,hero_info)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	--国家
	create_country_img(2, base_hero_info.country, bg_img_panel)
	--兵种
	create_type_img(2, base_hero_info.hero_type, bg_img_panel)
	--显示信息
	set_show_content_info(2, hero_uid, hero_id, false, temp_widget)

	--技能剩余点数
	set_left_point_info(temp_widget,left_point_num)
end

local function create_middle_card(hero_uid, hero_id, left_point_num)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	set_middle_card_info(temp_widget, hero_uid, hero_id, left_point_num)

	initFrameWidgetDefault(temp_widget)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	return temp_widget
end

local function set_middle_card_info_spec( temp_widget, hero_uid, hero_id, is_need_event )
	local hero_info = heroData.getHeroInfo(hero_uid)
	local base_hero_info = Tb_cfg_hero[hero_id]
	if not base_hero_info then
		return
	end

	local hero_quality = base_hero_info.quality

	local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	bg_img_panel:removeAllChildrenWithCleanup(true)
	--头像
	local icon =create_icon_img(1, hero_id, bg_img_panel)
	icon:setScaleX((bg_img_panel:getContentSize().width-4)/icon:getContentSize().width)
	icon:setScaleY((bg_img_panel:getContentSize().height-4)/icon:getContentSize().height)
	--边框背景
	create_frame_image(2, hero_quality, bg_img_panel)
	--星数
	-- set_star_img(temp_widget,2, hero_quality,hero_info)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	--国家
	create_country_img(2, base_hero_info.country, bg_img_panel)
	--兵种
	create_type_img(2, base_hero_info.hero_type, bg_img_panel)
	--显示信息
	set_show_content_info(2, hero_uid, hero_id, is_need_event, temp_widget)
end


local function offset_samll_frame_state(temp_widget)
	if not temp_widget then return end
	local img_center_tips = uiUtil.getConvertChildByName(temp_widget,"img_center_tips")

	local parent_panel = uiUtil.getConvertChildByName(temp_widget,"img_state_bg")
	local state_img = uiUtil.getConvertChildByName(parent_panel,"state_img")

	if not state_img then 
		img_center_tips:setPosition(cc.p(0,37))
	else
		-- state_img:setPosition(cc.p(state_img:getContentSize().width/2 + 5,0))
		-- state_img:ignoreContentAdaptWithSize(false)
		-- state_img:setAnchorPoint(cc.p(0,0.5))
		-- state_img:setPosition(cc.p(0,0))
		-- parent_panel:setVisible(true)
		-- state_img:setVisible(true)
		if img_center_tips:isVisible() and state_img:isVisible() then 
			parent_panel:setPosition(cc.p(0,48))
			img_center_tips:setPosition(cc.p(0,29))
		else
			parent_panel:setPosition(cc.p(0,37))
			img_center_tips:setPosition(cc.p(0,37))
		end
	end
end

local function set_center_txt_tips(temp_widget,txt,visble)
	if not temp_widget then return end
	local img_center_tips = uiUtil.getConvertChildByName(temp_widget,"img_center_tips")
	if not img_center_tips then return end
	img_center_tips:setVisible(visble)

	local label_txt_tips = uiUtil.getConvertChildByName(img_center_tips,"label_txt_tips")
	if not label_txt_tips then return end
	label_txt_tips:setText(txt)
	offset_samll_frame_state(temp_widget)

	-- TODOTK
	
	
	
end

local function create_middle_card_special( hero_uid, hero_id, is_need_event )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	set_middle_card_info_spec(temp_widget, hero_uid, hero_id, is_need_event)

	initFrameWidgetDefault(temp_widget)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	return temp_widget
end

local function reset_small_card_info(temp_widget)
	local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	local other_img_panel = tolua.cast(temp_widget:getChildByName("other_img_panel"), "Layout")
	bg_img_panel:removeAllChildrenWithCleanup(true)
	other_img_panel:removeAllChildrenWithCleanup(true)
	temp_widget:setTouchEnabled(false)
	set_center_txt_tips(temp_widget,"",false)

	local parent_panel = uiUtil.getConvertChildByName(temp_widget,"img_state_bg")
	parent_panel:setVisible(false)
end

local function set_small_card_info(temp_widget, hero_uid, hero_id, is_need_event)
	local hero_info = heroData.getHeroInfo(hero_uid)
	local base_hero_info = Tb_cfg_hero[hero_id]
	if not base_hero_info then
		return
	end

	local hero_quality = base_hero_info.quality

	local bg_img_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	local other_img_panel = tolua.cast(temp_widget:getChildByName("other_img_panel"), "Layout")
	bg_img_panel:removeAllChildrenWithCleanup(true)
	other_img_panel:removeAllChildrenWithCleanup(true)
	--头像
	create_icon_img(3, hero_id, bg_img_panel)
	--边框背景
	create_frame_image(3, hero_quality, bg_img_panel)
	--星数
	-- set_star_img(temp_widget,3, hero_quality,hero_info)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	--国家
	create_country_img(3, base_hero_info.country, other_img_panel)
	--兵种
	create_type_img(3, base_hero_info.hero_type, other_img_panel)
	--显示信息
	set_show_content_info(3, hero_uid, hero_id, is_need_event, temp_widget)

	set_center_txt_tips(temp_widget,"",false) 
	local parent_panel = uiUtil.getConvertChildByName(temp_widget,"img_state_bg")
	parent_panel:setVisible(false)
end

local function create_small_card(hero_uid, hero_id, is_need_event)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
	set_small_card_info(temp_widget, hero_uid, hero_id, is_need_event)

	initFrameWidgetDefault(temp_widget)
	setAdvancedDetail(temp_widget,hero_uid,hero_id)
	return temp_widget
end

local function create_mini_card(hero_uid, hero_id, is_need_event )
	if Tb_cfg_hero_rect[hero_id][4] == "" then
		return false
	end
		
	local pClip=CCClippingNode:create()
	pClip:setAlphaThreshold(0.5)
	local card = ImageView:create()
	local res_img_name = "gameResources/card/card_" .. hero_id .. ".png"
	card:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)
	card:setTextureRect(CCRectMake(Tb_cfg_hero_rect[hero_id][4][1], Tb_cfg_hero_rect[hero_id][4][2], Tb_cfg_hero_rect[hero_id][4][3], Tb_cfg_hero_rect[hero_id][4][4]))
	cardTextureManager.add_new_card_file(res_img_name)

	local node = CCDrawNode:create()
	local radius = Tb_cfg_hero_rect[hero_id][4][4]/2
	node:drawDot(cc.p(radius,radius), radius, ccc4f(0,0,0,1))

	local render = CCRenderTexture:create(radius*2, radius*2,kCCTexture2DPixelFormat_RGBA8888)
	render:begin()
	node:visit()
	render:endToLua()

	local pStencil = cc.Sprite:createWithTexture(render:getSprite():getTexture())
	pClip:setStencil(pStencil)
	pClip:setInverted(false)

	pClip:addChild(card)
	pClip:setScale(Tb_cfg_hero_rect[hero_id][4][5])
	return pClip
end

local function get_state_img_by_type(new_type)
	local icon_name = ""
	if new_type == heroStateDefine.not_deploy then
		icon_name = ResDefineUtil.ui_card_state[1]
	elseif new_type == heroStateDefine.other_place then
		icon_name = ResDefineUtil.ui_card_state[2]
	elseif new_type == heroStateDefine.chuzheng then
		icon_name = ResDefineUtil.ui_card_state[3]
	elseif new_type == heroStateDefine.returning then
		icon_name = ResDefineUtil.ui_card_state[4]
	elseif new_type == heroStateDefine.yuanjun then
		icon_name = ResDefineUtil.ui_card_state[5]
	elseif new_type == heroStateDefine.zhuzha then
		icon_name = ResDefineUtil.ui_card_state[6]
	elseif new_type == heroStateDefine.zengbing then
		icon_name = ResDefineUtil.ui_card_state[7]
	elseif new_type == heroStateDefine.zjsleep then
		icon_name = ResDefineUtil.ui_card_state[3]
	elseif new_type == heroStateDefine.inarmy then
		icon_name = ResDefineUtil.ui_card_state[8]
	elseif new_type == heroStateDefine.selected_nomal then
		icon_name = ResDefineUtil.ui_card_state[9]
	elseif new_type == heroStateDefine.selected_attention then
		icon_name = ResDefineUtil.ui_card_state[10]
	elseif new_type == heroStateDefine.no_energy then
		icon_name = ResDefineUtil.ui_card_state[11]
	elseif new_type == heroStateDefine.hurted then
		icon_name = ResDefineUtil.ui_card_state[12]
	elseif new_type == heroStateDefine.prepare then
		icon_name = ResDefineUtil.ui_card_state[13]
	elseif new_type == heroStateDefine.unnormal then
		icon_name = ResDefineUtil.ui_card_state[14]
	end

	return icon_name
end



local function set_attention_content(temp_widget,visble,txt)
	if not temp_widget then return end
	local img_attention = tolua.cast(temp_widget:getChildByName("img_attention"),"ImageView")
	if not img_attention then return end
	img_attention:setVisible(visble)
	local txt_attention = tolua.cast(img_attention:getChildByName("txt_attention"),"Label")
	txt_attention:setText(txt)
end

-- show_type 1,2,3 分别对应大，中，小三种卡片狂
-- new_state 0 为没有状态，其他分别对应heroStateDefine中的值
local function set_hero_state(temp_widget, show_type, new_state)
	local parent_panel = nil
	if show_type == 1 or show_type == 2 then
		parent_panel = tolua.cast(temp_widget:getChildByName("bg_img_panel"), "Layout")
	else
		parent_panel = uiUtil.getConvertChildByName(temp_widget,"img_state_bg")
	end

	local state_img = uiUtil.getConvertChildByName(parent_panel,"state_img")

	if new_state == 0 then
		if state_img then
			state_img:setVisible(false)
		end
		if show_type == 3 then 
			parent_panel:setVisible(false)
		end
		return
	end

	parent_panel:setVisible(true)

	if not state_img then
		
		if show_type == 1 then
			state_img = ImageView:create()
			state_img:setName("state_img")
			state_img:setPosition(cc.p(145,239))
		elseif show_type == 2 then
			state_img = ImageView:create()
			state_img:setPosition(cc.p(77,70))
			state_img:setName("state_img")
		elseif show_type == 3 then
			-- state_img:setScale(0.8)
			
			-- state_img:ignoreContentAdaptWithSize(false)
			-- state_img:setAnchorPoint(cc.p(0,0.5))
			-- state_img:setPosition(cc.p(state_img:getSize().width/2 + 5,0))
		end
		parent_panel:addChild(state_img)
	end

	if show_type == 3 and state_img then 

	end

	state_img:loadTexture(get_state_img_by_type(new_state), UI_TEX_TYPE_PLIST)
	state_img:setVisible(true)

	if show_type == 3 then 
		offset_samll_frame_state(temp_widget)
	end
end

local function set_hero_tips_content(temp_widget, show_type, content, show_or_not)
	local img_attention = tolua.cast(temp_widget:getChildByName("img_attention"),"ImageView")
	if not img_attention then
		return
	end

	if show_or_not then
		local txt_attention = tolua.cast(img_attention:getChildByName("txt_attention"),"Label")
		--img_attention:setPositionY(48)
		txt_attention:setText(content)
		img_attention:setVisible(true)
	else
		img_attention:setVisible(false)
	end
end


cardFrameInterface = {
						create_big_card = create_big_card,
						create_middle_card = create_middle_card,
						create_small_card = create_small_card,
						test_icon_img = test_icon_img,
						create_middle_card_special = create_middle_card_special,
						--find_hero_id_for_no_img = find_hero_id_for_no_img,
						set_big_card_info = set_big_card_info,
						set_middle_card_info = set_middle_card_info,
						reset_middle_card_info = reset_middle_card_info,
						set_middle_touch_sign_related = set_middle_touch_sign_related,
						set_small_card_info = set_small_card_info,
						reset_small_card_info = reset_small_card_info,
						set_hero_state	= set_hero_state,
						set_hero_tips_content = set_hero_tips_content,
						set_attention_content = set_attention_content,	
						set_lv_images = set_lv_images,
						set_army_count = set_army_count,
						set_left_point_info = set_left_point_info,
						set_center_txt_tips = set_center_txt_tips,
						get_hp_txt = get_hp_txt,
						create_mini_card = create_mini_card,
						-- setAdvancedMaxFlag = setAdvancedMaxFlag,

						doSetAdvancedDetail = doSetAdvancedDetail,
						setAdvancedDetail = setAdvancedDetail,
						showAdvacedMaxEffect = showAdvacedMaxEffect,
						showAdvancedStarEffect = showAdvancedStarEffect,
}
