--邮件主界面
module("worldProcessManager", package.seeall)

local m_main_layer = nil
local m_main_widget = nil
local m_backPanel = nil

local m_old_height = nil 		--工程默认底图高度
local m_divide_height = nil 	--内容上下框边距

local function do_remove_self( )
	if m_main_layer then
		worldProStateManager.remove_self()
		worldProContentManager.remove_self()
		worldProData.remove()

		m_main_widget = nil

		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end

		m_main_layer:removeFromParentAndCleanup(true)
		m_main_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.WORLD_PROCESS_MAIN_UI)
	end
end

function remove_self()
    if m_backPanel then
    	uiManager.hideConfigEffect(uiIndexDefine.WORLD_PROCESS_MAIN_UI, m_main_layer, do_remove_self, 999, {m_backPanel:getMainWidget()})
    end
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	return false
end

function update_show_level(is_most_above)
	if worldProStateManager then
		worldProStateManager.update_scroll_state(is_most_above)
	end

	if worldProContentManager then
		worldProContentManager.update_scroll_state(is_most_above)
	end
end

local function init_content_layout()
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	local left_panel = tolua.cast(m_main_widget:getChildByName("left_img"), "ImageView")
	local right_panel = tolua.cast(m_main_widget:getChildByName("right_img"), "ImageView")

	local new_panel_height = bg_img:getSize().height - m_divide_height * 2
	local panel_y_offset = bg_img:getSize().height - m_old_height
	left_panel:setSize(CCSize(left_panel:getSize().width, new_panel_height))
	left_panel:setPositionY(left_panel:getPositionY() - panel_y_offset/2)

	right_panel:setSize(CCSize(right_panel:getSize().width, new_panel_height))
	right_panel:setPositionY(right_panel:getPositionY() - panel_y_offset/2)

	require("game/world_process/worldProStateManager")
	worldProStateManager.create(left_panel)

	require("game/world_process/worldProContentManager")
	worldProContentManager.create(right_panel)

	worldProStateManager.revert_last_close_state()
end

function create()
	if m_main_layer then
		return
	end

	require("game/world_process/worldProData")
	worldProData.create()

	m_divide_height = 19 + 9
 
	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/shijiejindu_1.json")
	m_backPanel = UIBackPanel.new()
	local show_widget = m_backPanel:create(m_main_widget, remove_self, panelPropInfo[uiIndexDefine.WORLD_PROCESS_MAIN_UI][2], false, true)

	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	m_old_height = bg_img:getSize().height
	UIListViewSize.definedUIpanel(m_main_widget, bg_img)

	init_content_layout()

	m_main_layer = TouchGroup:create()
	m_main_layer:addWidget(show_widget)
	uiManager.add_panel_to_layer(m_main_layer, uiIndexDefine.WORLD_PROCESS_MAIN_UI)
	uiManager.showConfigEffect(uiIndexDefine.WORLD_PROCESS_MAIN_UI, m_main_layer, nil, 999, {show_widget})
end