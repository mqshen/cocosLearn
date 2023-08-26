--生成一张黑白的图片
module("GraySprite", package.seeall)
local function setSpriteColor(sprite,arrNotGray, isColor )
	local tempLayout = tolua.cast(sprite,"Widget")
	if tempLayout:getDescription() == "ImageView" or tempLayout:getDescription() == "Label" then
		local flag = true
		for i, v in ipairs(arrNotGray or {}) do
			if tempLayout:getName() == v then
				flag = false
				break
			end
		end
		if flag == true then
			if not isColor then
				tolua.cast(tempLayout:getVirtualRenderer(),"CCSprite"):setGray(kCCSpriteGray)
			else
				tolua.cast(tempLayout:getVirtualRenderer(),"CCSprite"):setGray(kCCSpriteEffectNone)
			end
		end
	end
end

function create( sprite,arrNotGray, isColor)
	if not sprite then return end
	if sprite:getChildren():count() == 0 then
		setSpriteColor(sprite,arrNotGray, isColor )
	else
		setSpriteColor(sprite,arrNotGray, isColor )
		for i=0, sprite:getChildren():count()-1 do
		    local tempLayout = tolua.cast(sprite:getChildren():objectAtIndex(i),"Widget")
		    GraySprite.create(tempLayout,arrNotGray, isColor)
		end
	end
end