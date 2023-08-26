local opHeroStarFilter = {}

-- 武将卡星级筛选器



function opHeroStarFilter.hitTest(widget,x,y)
	local panel_list = uiUtil.getConvertChildByName(widget,"panel_list")
	if not panel_list:isVisible() then return false end
	local img_mainbg = uiUtil.getConvertChildByName(panel_list,"img_mainbg")
	if img_mainbg:hitTest(cc.p(x,y)) then 
		return true
	else
		return false
	end
end

function opHeroStarFilter.create(parent,starList,starSelectedCallBack)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/xinjishaixuan.json")
	config.dump(starList)
	parent:addChild(widget)
	widget:setTouchEnabled(true)
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(1,0.5))

	widget:setPosition(cc.p(parent:getContentSize().width,parent:getContentSize().height/2))

	local label_selected_star = uiUtil.getConvertChildByName(widget,"label_selected_star")
	label_selected_star:setVisible(false)

	local label_selected_all = uiUtil.getConvertChildByName(widget,"label_selected_all")
	label_selected_all:setVisible(true) 


	local panel_list = uiUtil.getConvertChildByName(widget,"panel_list")
	panel_list:setVisible(false)



	local function switchVisible(isVisible) 
		local isEnable = isVisible
		panel_list:setVisible(isEnable)
		local img_mainbg = uiUtil.getConvertChildByName(panel_list,"img_mainbg")
		img_mainbg:setTouchEnabled(isEnable)

		local item = uiUtil.getConvertChildByName(panel_list,"img_btnStar")
		item:setTouchEnabled(isEnable)
		for i = 1, #starList do 
			item = uiUtil.getConvertChildByName(panel_list,"img_btnStar_" .. starList[i])
			item:setTouchEnabled(isEnable)
		end
	end
	local btn_sort = uiUtil.getConvertChildByName(widget,"btn_sort")
	btn_sort:setTouchEnabled(true)
	btn_sort:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			
			local isVisible = not panel_list:isVisible()
			switchVisible(isVisible)
		end
	end)

	

	local total_h = 0
	local panel_header = uiUtil.getConvertChildByName(panel_list,"panel_header")
	total_h = total_h + panel_header:getSize().height
	local img_btnStar = uiUtil.getConvertChildByName(panel_list,"img_btnStar")
	total_h = total_h + (#starList + 1) * img_btnStar:getSize().height
	total_h = total_h + 4
	

	local img_mainbg = uiUtil.getConvertChildByName(panel_list,"img_mainbg")
	img_mainbg:setSize(CCSizeMake(img_mainbg:getSize().width, total_h))
	img_mainbg:setTouchEnabled(false)

	local center_y = img_mainbg:getPositionY()
	local last_pos_y = center_y +  total_h/2 - panel_header:getSize().height - 2
	panel_header:setPositionY( last_pos_y )

	last_pos_y = last_pos_y - img_btnStar:getSize().height/2
	img_btnStar:setPositionY(last_pos_y)




	-- 0 是全部 
	local function onSelectStarType(starType)
		local item = uiUtil.getConvertChildByName(panel_list,"img_btnStar")
		local img_flagSelected = uiUtil.getConvertChildByName(item,"img_flagSelected")
		img_flagSelected:setVisible(starType == 0)
		item:setTouchEnabled( not (starType == 0))

		for i = 1, #starList do 
			item = uiUtil.getConvertChildByName(panel_list,"img_btnStar_" .. starList[i])
			img_flagSelected = uiUtil.getConvertChildByName(item,"img_flagSelected")
			img_flagSelected:setVisible(starType == starList[i])
			item:setTouchEnabled( not (starType == starList[i]))
		end


		local label_selected_star = uiUtil.getConvertChildByName(widget,"label_selected_star")
		label_selected_star:setVisible(starType ~= 0 )
		label_selected_star:setText(starType) 

		local label_selected_all = uiUtil.getConvertChildByName(widget,"label_selected_all")
		label_selected_all:setVisible(starType == 0 )

		switchVisible(false)
		starSelectedCallBack(starType)
	end


	local clone_btnstar = nil

	for i = 1,#starList do 

		clone_btnstar = img_btnStar:clone()
		last_pos_y = last_pos_y - img_btnStar:getSize().height
		panel_list:addChild(clone_btnstar)
		clone_btnstar:setPosition(cc.p(img_btnStar:getPositionX(),last_pos_y))
		clone_btnstar:setName("img_btnStar_" .. starList[i])

		clone_btnstar:setTouchEnabled(false)
		clone_btnstar:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				onSelectStarType(starList[i])
			end
		end)

		local img_flagSelected = uiUtil.getConvertChildByName(clone_btnstar,"img_flagSelected")
		img_flagSelected:setVisible(false)

		local label_star = uiUtil.getConvertChildByName(clone_btnstar,"label_star")
		label_star:setText(starList[i] .. languagePack['heroCardLvName'])
	end



	


	img_btnStar:setTouchEnabled(false)
	img_btnStar:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			onSelectStarType(0)
		end
	end)



	return widget
end


return opHeroStarFilter 