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
Panel_83479:setSize(CCSize(132.0000, 41.0000))

--Create label_name
local label_name = Label:create()
label_name:setTextAreaSize(CCSize(0, 0))
label_name:setFontSize(16)
label_name:setText([[ ]])
label_name:setName("label_name")
label_name:setZOrder(2)
label_name:setTag(1948)
label_name:setCascadeColorEnabled(true)
label_name:setCascadeOpacityEnabled(true)
label_name:setAnchorPoint(cc.p(0.0000, 0.5000))
label_name:setPosition(cc.p(64.0000, 20.0000))
label_name:setColor(ccc3(254, 244, 206))
label_name:setSize(CCSize(8.0000, 16.0000))
Panel_83479:addChild(label_name)

--Create img_bg
local img_bg = ImageView:create()
img_bg:loadTexture("jinruzhucheng_wenzidiban.png",1)
img_bg:setScale9Enabled(true)
img_bg:setCapInsets(CCRect(40,15,88,10))
img_bg:setName("img_bg")
img_bg:setZOrder(1)
img_bg:setTag(1947)
img_bg:setCascadeColorEnabled(true)
img_bg:setCascadeOpacityEnabled(true)
img_bg:setAnchorPoint(cc.p(0.0000, 0.5000))
img_bg:setPosition(cc.p(4.0000, 20.0000))
img_bg:setSize(CCSize(131.0000, 40.0000))
Panel_83479:addChild(img_bg)

--Create btn_enterCity
local btn_enterCity = Button:create()
btn_enterCity:loadTextureNormal("jinruzhuchengtubiao.png",1)
btn_enterCity:loadTexturePressed("jinruzhuchengtubiao_2.png",1)
btn_enterCity:setTitleFontSize(14)
btn_enterCity:setTouchEnabled(false)
btn_enterCity:setName("btn_enterCity")
btn_enterCity:setZOrder(2)
btn_enterCity:setTag(3706)
btn_enterCity:setCascadeColorEnabled(true)
btn_enterCity:setCascadeOpacityEnabled(true)
btn_enterCity:setPosition(cc.p(39.0000, 22.0000))
btn_enterCity:setSize(CCSize(58.0000, 58.0000))
Panel_83479:addChild(btn_enterCity)

--Create img_lunxian
local img_lunxian = ImageView:create()
img_lunxian:loadTexture("lunxian_biaoshi.png",1)
img_lunxian:setName("img_lunxian")
img_lunxian:setZOrder(3)
img_lunxian:setTag(3769)
img_lunxian:setCascadeColorEnabled(true)
img_lunxian:setCascadeOpacityEnabled(true)
img_lunxian:setPosition(cc.p(1.0000, 25.0000))
img_lunxian:setSize(CCSize(42.0000, 48.0000))
Panel_83479:addChild(img_lunxian)

--Create img_army_num
local img_army_num = ImageView:create()
img_army_num:loadTexture("cardFrameSmall.png",1)
img_army_num:setName("img_army_num")
img_army_num:setZOrder(3)
img_army_num:setTag(4644)
img_army_num:setCascadeColorEnabled(true)
img_army_num:setCascadeOpacityEnabled(true)
img_army_num:setAnchorPoint(cc.p(0.0000, 0.0000))
img_army_num:setPosition(cc.p(41.0000, 24.0000))
img_army_num:setSize(CCSize(32.0000, 32.0000))
Panel_83479:addChild(img_army_num)

--Create label_num
local label_num = Label:create()
label_num:setTextAreaSize(CCSize(0, 0))
label_num:setFontSize(18)
label_num:setText([[8]])
label_num:setName("label_num")
label_num:setTag(4646)
label_num:setCascadeColorEnabled(true)
label_num:setCascadeOpacityEnabled(true)
label_num:setAnchorPoint(cc.p(0.0000, 0.0000))
label_num:setPosition(cc.p(11.0000, 7.0002))
label_num:setColor(ccc3(255, 248, 210))
label_num:setSize(CCSize(9.0000, 18.0000))
img_army_num:addChild(label_num)

--Create ImageView_mianzhan
local ImageView_mianzhan = ImageView:create()
ImageView_mianzhan:loadTexture("mianzhan_daditu_ziti.png",1)
ImageView_mianzhan:setName("ImageView_mianzhan")
ImageView_mianzhan:setZOrder(3)
ImageView_mianzhan:setTag(4993)
ImageView_mianzhan:setCascadeColorEnabled(true)
ImageView_mianzhan:setCascadeOpacityEnabled(true)
ImageView_mianzhan:setAnchorPoint(cc.p(0.0000, 0.5000))
ImageView_mianzhan:setPosition(cc.p(105.0000, 21.0000))
ImageView_mianzhan:setSize(CCSize(29.0000, 25.0000))
Panel_83479:addChild(ImageView_mianzhan)

--Create Animation
return Panel_83479
end
return widget_Panel_83479