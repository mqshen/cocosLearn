local function setBtnsVisible( flag )
	if map.getInstance() then
		map.getInstance():setTouchEnabled(flag)
		local touchLayer = mapData.getTouchLayer()
		touchLayer:setVisible(flag)
	end
end

mainScene  =  {
				 setBtnsVisible = setBtnsVisible
}