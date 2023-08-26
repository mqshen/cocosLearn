local widget_Panel_1412103 = {}
function widget_Panel_1412103:create()


--Create Panel_1412103
local Panel_1412103 = Layout:create()
Panel_1412103:setBackGroundColorType(1)
Panel_1412103:setBackGroundColor(ccc3(150, 200, 255))
Panel_1412103:setBackGroundColorOpacity(0)
Panel_1412103:setTouchEnabled(false)
Panel_1412103:setName("Panel_1412103")
Panel_1412103:setTag(5238)
Panel_1412103:setCascadeColorEnabled(true)
Panel_1412103:setCascadeOpacityEnabled(true)
Panel_1412103:setAnchorPoint(cc.p(0.0000, 0.0000))
Panel_1412103:setPosition(cc.p(0.0000, 0.0000))
Panel_1412103:setSize(CCSize(200.0000, 100.0000))

--Create mianzhan
local mianzhan = ImageView:create()
mianzhan:loadTexture("mianzhan.png",1)
mianzhan:setName("mianzhan")
mianzhan:setZOrder(1)
mianzhan:setTag(1600)
mianzhan:setCascadeColorEnabled(true)
mianzhan:setCascadeOpacityEnabled(true)
mianzhan:setPosition(cc.p(100.0000, 50.0000))
mianzhan:setScaleX(0.5000)
mianzhan:setScaleY(0.5000)
mianzhan:setSize(CCSize(400.0000, 200.0000))
Panel_1412103:addChild(mianzhan)

--Create Animation
return Panel_1412103
end
return widget_Panel_1412103