local m_whole_layer = nil
local m_remove_timer = nil

local m_last_reprot_id = nil

local function remove_resource_related()
	scheduler.remove(m_remove_timer)
	m_remove_timer = nil

	local temp_texture_1 = CCTextureCache:sharedTextureCache():textureForKey(ResDefineUtil.exercise_res[1])
	if temp_texture_1 and temp_texture_1:retainCount() == 1 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(ResDefineUtil.exercise_res[1])
	end

	local temp_texture_2 = CCTextureCache:sharedTextureCache():textureForKey(ResDefineUtil.army_set_res[2])
	if temp_texture_2 and temp_texture_2:retainCount() == 1 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(ResDefineUtil.army_set_res[2])
	end

	cardTextureManager.remove_cache()
	if exerciseMapManager then
		exerciseMapManager.remove_resource()
	end

	config.removeAnimationFile()
end

local function do_remove_self()
	if m_whole_layer then
		exerciseOpRequest.remove()
		exerciseBaseManager.remove_self()
		exerciseMapManager.remove_self()

		m_last_reprot_id = nil

		m_whole_layer:removeFromParentAndCleanup(true)
		m_whole_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_WHOLE_UI)

		UIUpdateManager.remove_prop_update(dbTableDesList.user_exercise.name, dataChangeType.update, exerciseWholeManager.deal_with_exercise_update)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_exercise_land.name, dataChangeType.update, exerciseWholeManager.deal_with_land_update)

		if m_remove_timer then
			scheduler.remove(m_remove_timer)
			m_remove_timer = nil
		end
		m_remove_timer = scheduler.create(remove_resource_related, 0.1)
	end
end

local function remove_self()
	if m_whole_layer then
		if comGuideInfo then
			comGuideInfo.deal_with_guide_stop()
		end
		
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_WHOLE_UI, m_whole_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x, y)
	return false
end

---[[
local function deal_with_select_guide()
	if not exerciseData.is_teach_type() then
		return
	end

	local temp_exercise_phase = exerciseData.get_teach_phase()
	if temp_exercise_phase == 1 and (not exerciseData.get_exercise_reward_state()) then
		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2014)
	end
end
--]]

local function deal_with_battle_finish()
	exerciseMapManager.deal_with_land_update()
	
	if exerciseData.get_exercise_reward_state() then
		require("game/exercise/exerciseFinishManager")
		exerciseFinishManager.create()
	else
		local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[3])
		if show_sign == 0 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3007)
			CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[3], 1)
		else
			deal_with_select_guide()
		end

		local temp_report_info = reportData.getReport(m_last_reprot_id)
		if temp_report_info.result == 2 then
			exerciseMapManager.play_win_anim()
		end
	end
end

local function deal_with_fight_finish(fight_id_list)
	if #fight_id_list == 0 then
		return
	end

	m_last_reprot_id = fight_id_list[#fight_id_list]
	
	PracticeReportData.requestPracticeReport(fight_id_list, deal_with_battle_finish)
end

local function create()
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_1.json")
	temp_widget:setTag(999)
	temp_widget:setSize(CCSizeMake(scene_width, scene_height))
	temp_widget:setTouchEnabled(true)

	require("game/exercise/exerciseBaseManager")
	exerciseBaseManager.create(temp_widget)
	require("game/exercise/exerciseMapManager")
	exerciseMapManager.create(temp_widget)
	require("game/exercise/exerciseEffectManager")
	exerciseEffectManager.create(temp_widget)

	m_whole_layer = TouchGroup:create()
	m_whole_layer:addWidget(temp_widget)

    uiManager.add_panel_to_layer(m_whole_layer, uiIndexDefine.EXERCISE_WHOLE_UI)
    --uiManager.showConfigEffect(uiIndexDefine.EXERCISE_WHOLE_UI, m_whole_layer)

    UIUpdateManager.add_prop_update(dbTableDesList.user_exercise.name, dataChangeType.update, exerciseWholeManager.deal_with_exercise_update)
    UIUpdateManager.add_prop_update(dbTableDesList.user_exercise_land.name, dataChangeType.update, exerciseWholeManager.deal_with_land_update)
end

local function on_enter()
	if m_whole_layer then
		return
	end

	require("game/dbData/exerciseData")
	require("game/exercise/exerciseOpRequest")
	exerciseOpRequest.create()

	create()

	exerciseEffectManager.play_enter_anim()
end

local function deal_with_exercise_update(packet)
	if packet.next_time then
		exerciseBaseManager.deal_with_change_cd_state()
	end

	if packet.exercise_count then
		exerciseBaseManager.deal_with_count_update()
	end
end

local function start_new_exercise()
	exerciseBaseManager.deal_with_change_exercise()
	exerciseMapManager.deal_with_change_exercise()

	exerciseEffectManager.deal_with_enter_guide()
	exerciseEffectManager.deal_with_enter_free_guide(false)
end

local function deal_with_land_update(packet)
	--exerciseMapManager.deal_with_land_update()
end

local function get_com_map_mask_area(temp_guide_id)
	if temp_guide_id == com_guide_id_list.CONST_GUIDE_2014 then
		return exerciseMapManager.get_com_guide_pos(), CCSizeMake(200, 100), CCSizeMake(200, 100)
	end
end

exerciseWholeManager = {
					on_enter = on_enter,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent,
					start_new_exercise = start_new_exercise,
					get_com_map_mask_area = get_com_map_mask_area,
					deal_with_select_guide = deal_with_select_guide,
					deal_with_fight_finish = deal_with_fight_finish,
					deal_with_exercise_update = deal_with_exercise_update,
					deal_with_land_update = deal_with_land_update
}