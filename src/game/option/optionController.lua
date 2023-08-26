-- 负责对主界面UI元素的一些控制

--移除状态
local m_bRemoveState = false

local function getIsIncity ()
	local current_in_city_id = mainBuildScene.getThisCityid()
    if current_in_city_id then return true end
    return false
end

--移除主界面元素
local function removeOptions( noAnimation)
	if m_bRemoveState == true then return end
	-- mainOption.remove_self()
	mainOption.setEnable(false,noAnimation)
	innerOptionLeft.setEnable(false)
	innerOptionRight.setEnable(false)
	m_bRemoveState = true
end

-- 重设主界面元素
local function resetOptions(noAnimation)
	if m_bRemoveState == false then return end
	-- mainOption.create()
	mainOption.setEnable(true,noAnimation)
	innerOptionLeft.setEnable(true)
	innerOptionRight.setEnable(true)
	-- mainOption.changeInCityState(getIsIncity())
	m_bRemoveState = false
end


optionController = {
	-- 移除恢复
	removeOptions = removeOptions,
	resetOptions = resetOptions
}

-- return optionController
