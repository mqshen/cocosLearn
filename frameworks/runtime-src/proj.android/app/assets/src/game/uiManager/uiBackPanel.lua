--全屏界面的底部
UIBackPanel=class()
function UIBackPanel:ctor()

end

--_widget:需要加入全屏界面的widget
--closeCallFun:关闭的回调
--titleName: 面板标题
-- backPanelNotVisible:是否显示底板
-- isNoDecorative : 是不是要隐藏装饰的花纹
local uiUtil = require("game/utils/ui_util")

function UIBackPanel:create( _widget,closeCallFun, titleName, backPanelNotVisible, isNoDecorative)
	local backnotVisible = false
	if backPanelNotVisible then
		backnotVisible = true
	end
	local winsize = config.getWinSize()
	self.widget = GUIReader:shareReader():widgetFromJsonFile("test/background.json")
	self.widget:setAnchorPoint(cc.p(0.5,0.5))
	self.widget:setPosition(cc.p(winsize.width/2, winsize.height/2))

	local panel_touch = tolua.cast(self.widget:getChildByName("Panel_touch"),"Layout")
	panel_touch:setAnchorPoint(cc.p(0.5,0.5))
	panel_touch:setPosition(cc.p(self.widget:getContentSize().width/2, self.widget:getContentSize().height/2))
	panel_touch:setSize(CCSize(winsize.width, winsize.height))

	LSound.openFullScreen()
	if backnotVisible then
		
	else
		local blackPanel = tolua.cast(self.widget:getChildByName("background"),"ImageView")
		blackPanel:setSize(CCSize(winsize.width+(blackPanel:getSize().width-960)*winsize.width/960, winsize.height+(blackPanel:getSize().height-640)*winsize.height/640))
		blackPanel:setVisible(true)
	end

	local point = self.widget:convertToNodeSpace(cc.p(winsize.width, winsize.height))

	self.closeBtn = tolua.cast(self.widget:getChildByName("close_btn"),"Button")
	self.closeBtn:setPosition(point)
	self.closeBtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if closeCallFun then
				closeCallFun()
			end
		end
	end)
	self.closeBtn:setScale(config.getgScale())

	self.line = tolua.cast(self.widget:getChildByName("top_line"),"ImageView")
	self.line:setPositionY(point.y)
	self.line:setSize(CCSize(winsize.width, self.line:getSize().height*config.getgScale()))

	local top_ = tolua.cast(self.line:getChildByName("top_"),"ImageView")
	top_:setSize(CCSize(winsize.width, (top_:getSize().height - 2)*config.getgScale()))

	local down_ = tolua.cast(self.line:getChildByName("down_"),"ImageView")
	down_:setSize(CCSize(winsize.width, down_:getSize().height*config.getgScale()))
	down_:setPositionY(-self.line:getSize().height)

	local point_left = self.widget:convertToNodeSpace(cc.p(0, winsize.height))
	local left_dragon = tolua.cast(self.widget:getChildByName("dragon_left"),"ImageView")
	left_dragon:setPosition(cc.p(point_left.x, point.y))
	left_dragon:setScale(config.getgScale())

	local left_right = tolua.cast(self.widget:getChildByName("dragon_right"),"ImageView")
	left_right:setPosition(cc.p(point.x, point.y))
	left_right:setScale(config.getgScale())

	local panel_top = tolua.cast(self.widget:getChildByName("Panel_top"),"Layout")
	panel_top:setAnchorPoint(cc.p(0,1))
	panel_top:setPosition(point_left)
	panel_top:setScale(config.getgScale())

	if titleName then
		local lable = tolua.cast(panel_top:getChildByName("Label_title"),"Label")
		lable:setText(titleName)
	end

	-- local left = tolua.cast(self.widget:getChildByName("left"),"ImageView")
	-- left:setPosition(cc.p(point_left.x, point.y-self.line:getSize().height))
	-- left:setScale(config.getgScale())

	-- local right = tolua.cast(self.widget:getChildByName("right"),"ImageView")
	-- right:setPosition(cc.p(point.x, point.y-self.line:getSize().height))
	-- right:setScale(config.getgScale())

	-- local point_bottom = self.widget:convertToNodeSpace(cc.p(0, 0))
	local panel = tolua.cast(self.widget:getChildByName("Panel_110403"),"Layout")
	panel:setAnchorPoint(cc.p(0,1))
	panel:setSize(CCSize(winsize.width, winsize.height - self.line:getSize().height))
	panel:setPosition(cc.p(point_left.x, self:getLinePos( ) - 10*config.getgScale()))

	local backImage = ImageView:create()
	backImage:loadTexture("test/res_single/gongdian.png", UI_TEX_TYPE_LOCAL)
	panel:addChild(backImage)
	backImage:setAnchorPoint(cc.p(0.5,1))
	backImage:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height+10*config.getgScale()))
	backImage:setScaleX( winsize.width/backImage:getSize().width)
	backImage:setScaleY( winsize.height/backImage:getSize().height)

	local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,255*0.5), winsize.width, winsize.height - self.line:getSize().height)
	panel:addChild(colorLayer)
	colorLayer:ignoreAnchorPointForPosition(false)
	colorLayer:setAnchorPoint(cc.p(0.5,1))
	colorLayer:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height+10*config.getgScale()))

	panel:addChild(_widget)
	_widget:setAnchorPoint(cc.p(0.5,1))
	_widget:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height))
	_widget:setScale(config.getgScale())


	--底纹
	self.color = tolua.cast(self.widget:getChildByName("bottom_ImageView"),"ImageView")
	if isNoDecorative then
		self.color:setVisible(false)
	else
		local point = self.widget:convertToNodeSpace(cc.p(winsize.width/2, winsize.height))
		local temp_point = panel:convertToWorldSpace(cc.p(_widget:getPositionX(), _widget:getPositionY()-_widget:getContentSize().height*config.getgScale()))
		local node_point = self.widget:convertToNodeSpace(temp_point)
		-- color:setScale(config.getgScale())
		self.color:setPosition(cc.p(point.x, node_point.y))

		-- point = color:getParent():convertToWorldSpace(node_point)
		local scaleX = winsize.width/self.color:getSize().width
		local scaleY = temp_point.y/self.color:getSize().height
		self.color:setScale((scaleX>scaleY and scaleX) or scaleY)
		self.color:setVisible(true)
	end
	
	return self.widget
end

function UIBackPanel:setColorVisible(flag )
	if self.color then
		self.color:setVisible(flag)
	end
end

function UIBackPanel:getLinePos( )
	if self.line then
		return self.line:getPositionY()-self.line:getSize().height
	end
	return nil
end

function UIBackPanel:getCloseBtn( )
	return self.closeBtn
end

function UIBackPanel:remove( )
	if self.widget then
		self.widget:removeFromParentAndCleanup(true)
		LSound.closeFullScreen()
		self.widget = nil
		self.line = nil
		self.color = nil
	end
end

function UIBackPanel:getMainWidget()
	return self.widget
end