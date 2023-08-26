local m_pic_layer = nil
local m_pic_img = nil
local m_tips_id = nil
local m_fun_call = nil 		--关闭回调
local m_is_play_anim = nil

local function remove_texture_cache()
	local res_name = ResDefineUtil.tips_res[m_tips_id]

	local temp_texture = CCTextureCache:sharedTextureCache():textureForKey(res_name)
	if temp_texture and temp_texture:retainCount() == 1 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(res_name)
	end

	m_tips_id = nil
end

local function do_remove_self()
	if m_pic_layer then
		m_is_play_anim = nil
		m_pic_img = nil

		m_pic_layer:removeFromParentAndCleanup(true)
		m_pic_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.FC_TIPS_UI)

		if m_fun_call then
			m_fun_call()
			m_fun_call = nil
		end

		remove_texture_cache()
	end
end

local function remove_self()
    if m_pic_layer then
       uiManager.hideConfigEffect(uiIndexDefine.FC_TIPS_UI, m_pic_layer, do_remove_self)
    end 
end

local function dealwithTouchEvent(x,y)
	if m_pic_layer then
		if not m_is_play_anim then
			remove_self()
		end
		
		return true
	else
		return false
	end
end

local function deal_with_animation_finished()
	m_is_play_anim = false
end

local function play_anim()
	local fade_in = CCFadeIn:create(0.2)
	local scale_to = CCScaleTo:create(0.2, config.getgScale())
	local temp_spawn = CCSpawn:createWithTwoActions(fade_in, scale_to)
	local fun_call = cc.CallFunc:create(deal_with_animation_finished)
	local temp_sep = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)

	m_pic_img:runAction(temp_sep)
end

local function create(tips_id, temp_funcall)
	if m_pic_layer then
		return
	end

	m_tips_id = tips_id
	if temp_funcall then
		m_fun_call = temp_funcall
	end
	m_is_play_anim = true

	m_pic_img = ImageView:create()
	m_pic_img:setScale(0.8 * config.getgScale())
	--m_pic_img:setOpacity(0)
	m_pic_img:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	m_pic_img:loadTexture(ResDefineUtil.tips_res[m_tips_id], UI_TEX_TYPE_LOCAL)

    m_pic_layer = TouchGroup:create()
    m_pic_layer:addWidget(m_pic_img)
	uiManager.add_panel_to_layer(m_pic_layer, uiIndexDefine.FC_TIPS_UI)
    uiManager.showConfigEffect(uiIndexDefine.FC_TIPS_UI, m_pic_layer)

    play_anim()
end

picTipsManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent

}