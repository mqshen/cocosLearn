-- voicePlayAnimation.lua
-- 播录音的动画
module("VoicePlayAnimation", package.seeall)
local dt = 0.3
function create( widget,fileName )
	widget:setTouchEnabled(false)
	local Button_play = tolua.cast(widget:getChildByName("Button_play"),"Button")
	Button_play:setBright(false)
	VoiceMgr.playRecord(fileName)

	local ImageView_playing_1 = tolua.cast(widget:getChildByName("ImageView_playing_1"),"ImageView")
	ImageView_playing_1:setOpacity(0)
	local ImageView_playing_2 = tolua.cast(widget:getChildByName("ImageView_playing_2"),"ImageView")
	ImageView_playing_1:setOpacity(0)

	local action1 = animation.sequence({cc.CallFunc:create(function ( )
		ImageView_playing_1:setOpacity(255)
		ImageView_playing_2:setOpacity(0)
	end), cc.DelayTime:create(dt), cc.CallFunc:create(function ( )
		ImageView_playing_1:setOpacity(255)
		ImageView_playing_2:setOpacity(255)
	end),cc.DelayTime:create(dt), cc.CallFunc:create(function ( )
		ImageView_playing_1:setOpacity(0)
		ImageView_playing_2:setOpacity(0)
	end),cc.DelayTime:create(dt)})
	widget:runAction(CCRepeatForever:create(action1))
end

function remove( widget,fileName )
	widget:setTouchEnabled(true)
	VoiceMgr.stopPlay(fileName)
	local ImageView_playing_1 = tolua.cast(widget:getChildByName("ImageView_playing_1"),"ImageView")
	ImageView_playing_1:setOpacity(255)
	local ImageView_playing_2 = tolua.cast(widget:getChildByName("ImageView_playing_2"),"ImageView")
	ImageView_playing_1:setOpacity(255)

	local Button_play = tolua.cast(widget:getChildByName("Button_play"),"Button")
	Button_play:setBright(true)
	widget:stopAllActions()
end