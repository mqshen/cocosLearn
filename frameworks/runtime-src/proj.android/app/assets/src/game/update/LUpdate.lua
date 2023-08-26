module("LUpdate", package.seeall)

local loginLoadingBar = require("game/login/login_loading_bar")

local main_layer = nil
local patch_size_each = nil
local total_size = nil
local total_downLoad = nil
local last_patch_size = nil
local beginTime = 0
-- local isNeedRestart = nil

-- local record_table_one = nil
-- local record_table_two = nil

local updateTips = require("game/update/update_tips")

local function beginUpdate( )
	configBeforeLoad.setUpdateTime(os.time())
	beginTime = os.time()
	CCUpdate:sharedUpdate():beginUpdate()
end

local function reUpdate( )
	CCUpdate:sharedUpdate():updateCheck(configBeforeLoad.getUpdateAddress(), configBeforeLoad.getUpdateDir())
end

local function createLoadingBar()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_loading_bar.json")
	local bg_loading_bar = tolua.cast(temp_widget:getChildByName("bg_loading_bar"),"LoadingBar")

	
	local instance = loginLoadingBar.create()
	main_layer:addWidget(instance)
	instance:setScale(configBeforeLoad.getgScale())
	instance:ignoreAnchorPointForPosition(false)
	instance:setAnchorPoint(cc.p(0.5,0))
	instance:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, 0))

end

-- 更新的size, text 需要显示的内容, arg text里面需要动态替换的参数， confirmCB确定按钮的回调，btnStr确定按钮显示的文字
local function updateTipsUI( size, text, arg,confirmCB, btnStr)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/gengxing_tishi.json")
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	temp_widget:setTag(999)
	main_layer:addWidget(temp_widget)

	local cancelBtn = tolua.cast(temp_widget:getChildByName("Button_483354_0"),"Button")
	cancelBtn:addTouchEventListener(function (sender,eventType )
		if eventType == TOUCH_EVENT_ENDED then
			-- if size == -1 then
				-- cc.Director:getInstance():endToLua()
				configBeforeLoad.exitGame()
			-- else
				-- reUpdate()
			-- end
		end
	end)

	local downloadBtn = tolua.cast(temp_widget:getChildByName("Button_483354"),"Button")
	if btnStr then
		downloadBtn:setTitleText(btnStr)
	end
	downloadBtn:addTouchEventListener(function (sender,eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if size == 0 then
				temp_widget:removeFromParentAndCleanup(true)
				reUpdate()
			elseif size == -1 then
				-- cc.Director:getInstance():endToLua()
				-- configBeforeLoad.exitGame()
				if not confirmCB then
					configBeforeLoad.exitGame()
				else
					confirmCB()
				end
			else
				-- temp_widget:removeFromParentAndCleanup(true)
				-- beginUpdate( )
				-- createLoadingBar()
				if confirmCB then 
					confirmCB()
				end
			end
		end
	end)

	local panel = tolua.cast(temp_widget:getChildByName("Panel_488081"),"Layout")
	local _richText = RichText:create()
	_richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel:getSize().width, panel:getSize().height))
    _richText:setAnchorPoint(cc.p(0.5,0.5))
    _richText:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height/2))
    panel:addChild(_richText)

    local index = 1
    local temp
    local tempStr = string.gsub(text, "&", function (n)
    	temp = arg[index]
    	index = index + 1
    	return temp or "&"
    end)
    local tStr = configBeforeLoad.richText_split(tempStr)
    local re = nil
    local strTemp = ""
    for i,v in ipairs(tStr) do
    	if v[1] == 1 then
	    	re = RichElementText:create(i, ccc3(234,232,156), 255, v[2],configBeforeLoad.getFontName(), 22)
		else
			re = RichElementText:create(i, ccc3(198,82,82), 255, v[2],configBeforeLoad.getFontName(), 22)
		end
		strTemp = strTemp .. v[2]
		_richText:pushBackElement(re)
	end


	local record_table_one = {[1] = 1, [3] = 1, [5] = 1, [6] = 1, [9] = 1}
	local record_table_two = {[2] = 1, [4] = 1, [7] = 1, [8] = 1, [10] = 1}
	local touch_count = 0

	local setUpdate = function ( )
		if touch_count == 10 then
			for i, v in pairs(record_table_one) do
				if v == 1 then
					return
				end
			end

			for i, v in pairs(record_table_two) do
				if v == 1 then
					return
				end
			end
			CCUserDefault:sharedUserDefault():setStringForKey("DEBUG_MODE", "true", true)
		end
	end

	local Panel_touch_one = tolua.cast(temp_widget:getChildByName("Panel_touch_one"),"Layout")
	Panel_touch_one:setTouchEnabled(true)
	Panel_touch_one:addTouchEventListener(function (sender,eventType )
		if eventType == TOUCH_EVENT_ENDED then
			touch_count = touch_count + 1
			if record_table_one[touch_count] then
				record_table_one[touch_count] = 2
			end
			setUpdate()
		end
	end)

	local Panel_touch_two = tolua.cast(temp_widget:getChildByName("Panel_touch_two"),"Layout")
	Panel_touch_two:setTouchEnabled(true)
	Panel_touch_two:addTouchEventListener(function (sender,eventType )
		if eventType == TOUCH_EVENT_ENDED then
			touch_count = touch_count + 1
			if record_table_two[touch_count] then
				record_table_two[touch_count] = 2
			end
			setUpdate()
		end
	end)

	
end

--获取版本号文件的时候发生网络错误
local function onConnectError( )
	-- remove()
	if configBeforeLoad.getDebugEnvironment() then
		-- if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
		-- 	runSceneBegin()
		-- else
			remove()
			UpdateUI.setUpdateComplete(true)
		-- end
	else
		
		updateTipsUI(0,languageBeforeLogin[3])
		
	end
	-- CCUpdate:sharedUpdate():destroyInstance()
end

local function changeSize( iSize )
	local size = iSize
	local str = "KB"
	if size > 1024 and size < 1024*1024 then
		size = math.floor(size/1024)
		str = "KB"
	elseif size >= 1024*1024 then
		size = string.format("%0.1f", size/1024/1024)
		str = "MB"
	else
		size = 1
		str = "KB"
	end
	return size, str
end

--每个文件下载进度条显示
local function onProgress(percent )

	local _downLoad = patch_size_each*percent/100+total_downLoad
	local total, _str = changeSize(total_size)
	local size, str = changeSize( patch_size_each )
	loginLoadingBar.setPercent(math.floor(100*_downLoad/total_size))
	loginLoadingBar.setPatchPercent(string.format("%0.1f",total*(_downLoad/total_size)).._str.."/"..total.._str)
end

--每个patch下载完成
local function onDownLoadSuccess( )

end

--下载patch错误
local function onDownLoadError( error )
	if configBeforeLoad.getDebugEnvironment() then
		if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
			runSceneBegin()
		else
			remove()
			UpdateUI.setUpdateComplete(true)
		end
	else
		updateTipsUI(0,languageBeforeLogin[4])
	end
	-- CCUpdate:sharedUpdate():destroyInstance()
end

--更新完成
local function onUpdateComplete( reStartGame)
	if beginTime ~= 0 then
		beginTime = os.time() - beginTime
	end

	configBeforeLoad.setUpdateUseTime(beginTime)
	remove()
	if reStartGame == 0 then
		VoiceRecord:sharedVoiceRecordMgr():removeOneDir("VoiceAmr")
		UpdateUI.setUpdateComplete(true)
		updateTips.remove()
	end
	
	if reStartGame == 1 then
		StartAnimation.reStartGame()
	end
	
	
	-- if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
	-- 	runSceneBegin()
	-- end
end

--更新需要提示信息
local function onShowTips(tips_type)
	if tips_type == 1 then
		--版本过低提示
		updateTipsUI(-1,languageBeforeLogin[2])
	end
end

--更新当前patch的名字
local function onUpdateFileName(sFileName )
	loginLoadingBar.setPatchName(languageBeforeLogin["ziliao"]..sFileName..languageBeforeLogin["tongbu"].."...")
end



--更新当前patch大小
local function onUpdateFileSize(iSize )
	patch_size_each = iSize
	total_downLoad = last_patch_size + total_downLoad

	last_patch_size = iSize
end

--这次更新总大小
local function onUpdateTotalSize(iSize )
	if iSize == 0 then
		beginUpdate( )
	else
		total_size = iSize
		last_patch_size = 0
		total_downLoad = 0
		if iSize <= 1024*1024 then
			beginUpdate( )
			createLoadingBar()
		else
			local size , str = changeSize( iSize )
			updateTipsUI(iSize,languageBeforeLogin[1], {size..str, "Wi-Fi"},function()
				if main_layer then
					local temp_widget = main_layer:getWidgetByTag(999)
					if temp_widget then
						temp_widget:removeFromParentAndCleanup(true)
					end
					beginUpdate( )
					createLoadingBar()
					updateTips.create()
				end
			end)
		end
	end
end

local function onUpdateFindNewVersion(url )
	updateTipsUI(-1,languageBeforeLogin[2], nil,function()
				sdkMgr:sharedSkdMgr():openURL(url)
			end,languageBeforeLogin["update"])
end

function remove( )
	beginTime = nil
	loginLoadingBar.remove()
	updateTips.remove()
	if main_layer then
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		-- isNeedRestart = nil
		-- record_table_two = nil
		-- record_table_one = nil
		patch_size_each = nil
		total_size = nil
		total_downLoad = nil
		last_patch_size = nil
		CCUpdate:sharedUpdate():destroyInstance()
	end
end

local function initUpdate( )
	CCUpdate:sharedUpdate():setTimeOut(3)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateConnectError, onConnectError)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateProgress, onProgress)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateSuccess, onDownLoadSuccess)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateError, onDownLoadError)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateEndUpdate, onUpdateComplete)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateTips, onShowTips)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateFileName, onUpdateFileName)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateFileSize, onUpdateFileSize)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateTotalSize, onUpdateTotalSize)
	CCUpdate:sharedUpdate():registerScriptHandler(kCCUpdateDownLoadAddress, onUpdateFindNewVersion)
	CCUpdate:sharedUpdate():updateCheck(configBeforeLoad.getUpdateAddress(), configBeforeLoad.getUpdateDir())
	
end

function create()
	if not main_layer then
		beginTime = 0
		main_layer = TouchGroup:create()
		cc.Director:getInstance():getRunningScene():addChild(main_layer)
	end
	-- createLoadingBar()
	initUpdate( )
end

function runSceneBegin(loaded)
	remove()
	-- require("game/login/sceneBeforeLogin")
    SceneBeforeLogin.onLoad(loaded)
end