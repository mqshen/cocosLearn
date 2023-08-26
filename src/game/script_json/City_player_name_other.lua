local widget_Panel_83479 = {}
function widget_Panel_83479:create()


--Create Panel_83479
local Panel_83479 = Layout:create()
Panel_83479:setBackGroundColorOpacity(0)
Panel_83479:setTouchEnabled(false)
Panel_83479:setName("Panel_83479")
Panel_83479:setTag(1945)
Panel_83479:setCascadeColorEnabled(true)
Panel_83479:setCascadeOpacityEnabled(true)
Panel_83479:setAnchorPoint(cc.p(0.0000, 0.0000))
Panel_83479:setPosition(cc.p(0.0000, 0.0000))
Panel_83479:setSize(CCSize(250.0000, 36.0000))

--Create img_flag
local img_flag = ImageView:create()
img_flag:loadTexture("qitawanjia_zhucheng.png",1)
img_flag:setName("img_flag")
img_flag:setZOrder(2)
img_flag:setTag(3708)
img_flag:setCascadeColorEnabled(true)
img_flag:setCascadeOpacityEnabled(true)
img_flag:setPosition(cc.p(20.0000, 16.0000))
img_flag:setSize(CCSize(37.0000, 37.0000))
Panel_83479:addChild(img_flag)

--Create label_name
local label_name = Label:create()
label_name:setTextAreaSize(CCSize(0, 0))
label_name:setFontSize(16)
label_name:setText([[ ]])
label_name:setName("label_name")
label_name:setTag(3709)
label_name:setCascadeColorEnabled(true)
label_name:setCascadeOpacityEnabled(true)
label_name:setAnchorPoint(cc.p(0.0000, 0.5000))
label_name:setPosition(cc.p(40.0000, 16.0000))
label_name:setColor(ccc3(206, 143, 190))
label_name:setSize(CCSize(95.0000, 27.0000))
Panel_83479:addChild(label_name)

--Create img_bg
local img_bg = ImageView:create()
img_bg:loadTexture("golden_plate_p.png",1)
img_bg:setScale9Enabled(true)
img_bg:setCapInsets(CCRect(10,10,198,14))
img_bg:setName("img_bg")
img_bg:setZOrder(-1)
img_bg:setTag(3707)
img_bg:setCascadeColorEnabled(true)
img_bg:setCascadeOpacityEnabled(true)
img_bg:setAnchorPoint(cc.p(0.0000, 0.5000))
img_bg:setPosition(cc.p(0.0000, 16.0000))
img_bg:setSize(CCSize(212.0000, 34.0000))
Panel_83479:addChild(img_bg)

--Create img_lunxian
local img_lunxian = ImageView:create()
img_lunxian:loadTexture("lunxian_biaoshi.png",1)
img_lunxian:setName("img_lunxian")
img_lunxian:setZOrder(3)
img_lunxian:setTag(3769)
img_lunxian:setCascadeColorEnabled(true)
img_lunxian:setCascadeOpacityEnabled(true)
img_lunxian:setPosition(cc.p(-8.0000, 19.0000))
img_lunxian:setSize(CCSize(42.0000, 48.0000))
Panel_83479:addChild(img_lunxian)

--Create img_army_num
local img_army_num = ImageView:create()
img_army_num:loadTexture("tishixinxi.png",1)
img_army_num:setName("img_army_num")
img_army_num:setZOrder(3)
img_army_num:setTag(4644)
img_army_num:setCascadeColorEnabled(true)
img_army_num:setCascadeOpacityEnabled(true)
img_army_num:setPosition(cc.p(34.0000, 34.0000))
img_army_num:setSize(CCSize(18.0000, 18.0000))
Panel_83479:addChild(img_army_num)

--Create ImageView_mianzhan
local ImageView_mianzhan = ImageView:create()
ImageView_mianzhan:loadTexture("mianzhan_daditu_ziti.png",1)
ImageView_mianzhan:setName("ImageView_mianzhan")
ImageView_mianzhan:setZOrder(3)
ImageView_mianzhan:setTag(4994)
ImageView_mianzhan:setCascadeColorEnabled(true)
ImageView_mianzhan:setCascadeOpacityEnabled(true)
ImageView_mianzhan:setAnchorPoint(cc.p(0.0000, 0.5000))
ImageView_mianzhan:setPosition(cc.p(113.0000, 15.0000))
ImageView_mianzhan:setSize(CCSize(29.0000, 25.0000))
Panel_83479:addChild(ImageView_mianzhan)

--Create Animation
return Panel_83479
end
return widget_Panel_83479