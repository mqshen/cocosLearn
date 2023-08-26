--全屏条目型ui的统一处理
module("UIListViewSize", package.seeall)
--mainPanel json文件返回的主panel
--backPanel 底板
--panel tableview add在上面的面板
--arrowPanel 下拉的向下箭头
--arrPanel 其他需要对齐的widget
function definedUIpanel( mainPanel,backPanel,panel,arrowPanel,arrPanel)
	local height = 0
	local winsize = config.getWinSize()
	local m_arrPanel = {}
	if backPanel then
		table.insert(m_arrPanel, backPanel)
	end

	if panel then
		table.insert(m_arrPanel, panel)
	end

	if arrPanel then
		for i, v in ipairs(arrPanel) do
			table.insert(m_arrPanel,v)
		end
	end

	local point = nil
	local temp_point = nil
	local backPanelHeight = nil
	if arrowPanel then
		-- arrowPanel:setAnchorPoint(cc.p(0.5,0))
		-- arrowPanel:setPositionY(arrowPanel:getPositionY() - arrowPanel:getSize().height/2)
		point = arrowPanel:convertToWorldSpace(cc.p(0,0))
		local _point = mainPanel:convertToNodeSpace(point)
		temp_point = arrowPanel:getParent():convertToNodeSpace(_point)
		arrowPanel:setPositionY(temp_point.y )
	end

	if m_arrPanel then
		for i, v in ipairs(m_arrPanel) do
			if v:getAnchorPoint().x == 0.5 and v:getAnchorPoint().y == 0.5 then
				v:setPosition(cc.p(v:getPositionX() - v:getSize().width/2,
											v:getPositionY() + v:getSize().height/2))
			elseif v:getAnchorPoint().x == 0 and v:getAnchorPoint().y == 0 then
				v:setPositionY(v:getPositionY() + v:getSize().height)
			elseif v:getAnchorPoint().x == 0.5 and v:getAnchorPoint().y == 1 then
				v:setPositionX(v:getPositionX() - v:getSize().width/2)
			end

			v:setAnchorPoint(cc.p(0,1))
			point = v:getParent():convertToWorldSpace(cc.p(v:getPositionX(),v:getPositionY()))
			temp_point = mainPanel:convertToNodeSpace(cc.p(point.x, point.y - v:getSize().height*config.getgScale()))
			height = temp_point.y / mainPanel:getContentSize().height
			backPanelHeight = (point.y - winsize.height*height)/config.getgScale()
			v:setSize(CCSize(v:getSize().width, backPanelHeight))
		end
	end
end