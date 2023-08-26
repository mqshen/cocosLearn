local widget_Panel_83482 = {}
function widget_Panel_83482:create()


--Create Panel_83482
local Panel_83482 = Layout:create()
Panel_83482:setBackGroundColorType(1)
Panel_83482:setBackGroundColor(ccc3(150, 200, 255))
Panel_83482:setBackGroundColorOpacity(0)
Panel_83482:setTouchEnabled(false)
Panel_83482:setName("Panel_83482")
Panel_83482:setTag(1946)
Panel_83482:setCascadeColorEnabled(true)
Panel_83482:setCascadeOpacityEnabled(true)
Panel_83482:setAnchorPoint(cc.p(0.0000, 0.0000))
Panel_83482:setPosition(cc.p(0.0000, 0.0000))
Panel_83482:setSize(CCSize(320.0000, 48.0000))

--Create label_name
local label_name = Label:create()
label_name:setTextAreaSize(CCSize(0, 0))
label_name:setFontSize(16)
label_name:setText([[ ]])
label_name:setName("label_name")
label_name:setZOrder(4)
label_name:setTag(1948)
label_name:setCascadeColorEnabled(true)
label_name:setCascadeOpacityEnabled(true)
label_name:setAnchorPoint(cc.p(0.0000, 0.5000))
label_name:setPosition(cc.p(50.0000, 28.0000))
label_name:setColor(ccc3(255, 217, 90))
label_name:setSize(CCSize(95.0000, 27.0000))
Panel_83482:addChild(label_name)

--Create ImageView_96912
local ImageView_96912 = ImageView:create()
ImageView_96912:loadTexture("Small_red_flag.png",1)
ImageView_96912:setName("ImageView_96912")
ImageView_96912:setZOrder(2)
ImageView_96912:setTag(2232)
ImageView_96912:setCascadeColorEnabled(true)
ImageView_96912:setCascadeOpacityEnabled(true)
ImageView_96912:setPosition(cc.p(31.0000, 28.0000))
ImageView_96912:setSize(CCSize(19.0000, 19.0000))
Panel_83482:addChild(ImageView_96912)

--Create img_bg
local img_bg = ImageView:create()
img_bg:loadTexture("City_small_panel.png",1)
img_bg:setName("img_bg")
img_bg:setZOrder(1)
img_bg:setTag(2231)
img_bg:setScale9Enabled(true)
img_bg:setCapInsets(CCRect(30,5,207,20))
img_bg:setCascadeColorEnabled(true)
img_bg:setCascadeOpacityEnabled(true)
img_bg:setAnchorPoint(cc.p(0.0000, 0.5000))
img_bg:setPosition(cc.p(0.0000, 28.0000))
img_bg:setSize(CCSize(267.0000, 30.0000))
Panel_83482:addChild(img_bg)

--Create City_name
local City_name = ImageView:create()
City_name:loadTexture("new_city_name_plate.png",1)
City_name:setName("City_name")
City_name:setTag(1947)
City_name:setCascadeColorEnabled(true)
City_name:setCascadeOpacityEnabled(true)
City_name:setPosition(cc.p(74.0000, 41.0000))
City_name:setSize(CCSize(107.0000, 112.0000))
Panel_83482:addChild(City_name)

--Create Animation
return Panel_83482
end
return widget_Panel_83482