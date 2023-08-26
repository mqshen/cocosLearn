--翻页控件
ClippingNode=class()

function ClippingNode:ctor()
	self.count = 0
	self.pageNumIndex = 1
end

function ClippingNode:create(width,height)
	self.clippingNode = CCScrollView:create()
    self.clippingNode:setViewSize(CCSizeMake(width,height))
    self.clippingNode:updateInset()
    self.clippingNode:setClippingToBounds(true)
    self.clippingNode:setBounceable(false)
    self.clippingNode:setTouchEnabled(false)
    return self.clippingNode
end

function ClippingNode:addPage(layer, isWidget )
	if not self.stencilLayer then
		self.stencilLayer = layer
		self.count = self.count + 1
	else
		if isWidget then
			self.stencilLayer:addWidget(layer)
		else
			self.stencilLayer:addChild(layer)
		end
		layer:setPosition(cc.p(self.count*self.stencilLayer:getContentSize().width,0))
		self.count = self.count + 1
	end
end

function ClippingNode:reloadData( )
	self.clippingNode:setContainer(self.stencilLayer)
end

function ClippingNode:remove( )
	if self.clippingNode then
		self.clippingNode:removeFromParentAndCleanup(true)
		self.clippingNode = nil
	end
	self.count = nil
	self.pageNumIndex = nil
	self.stencilLayer = nil
end

function ClippingNode:pageNextEvent( )
	if self.pageNumIndex >= self.count then
		return
	else
		self.stencilLayer:runAction(CCMoveTo:create(0.2, ccp(self.stencilLayer:getPositionX() - self.clippingNode:getContentSize().width,
									self.stencilLayer:getPositionY())))
		self.pageNumIndex = self.pageNumIndex + 1
		return self.pageNumIndex
	end
end

function ClippingNode:pageBackEvent( )
	if self.pageNumIndex <= 1 then
		return
	else
		self.stencilLayer:runAction(CCMoveTo:create(0.2, ccp(self.stencilLayer:getPositionX() + self.clippingNode:getContentSize().width,
									self.stencilLayer:getPositionY())))
		self.pageNumIndex = self.pageNumIndex - 1
		return self.pageNumIndex
	end
end

function ClippingNode:getCurPage( )
	return self.pageNumIndex
end