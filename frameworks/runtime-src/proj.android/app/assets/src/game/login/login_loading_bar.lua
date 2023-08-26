local loginLoadingBar = {}

local instance = nil
local patch_name = nil
local patch_percent = nil

local word_percent_begin = nil
local word_percent_end = nil

local m_tLoadedWord = nil
local function getConvertChildByName(parent,childName)
	assert(childName, "why get a nil child")
    local child = parent:getChildByName(childName)
    if child then 
       tolua.cast(child, child:getDescription())
    else
        -- print("node named["..childName.."]not found")
        -- print(debug.traceback())
    end
    return child
end


function loginLoadingBar.remove()
	if instance then 
		instance:removeFromParentAndCleanup(true)
		instance = nil
		patch_name = nil
		patch_percent = nil
		m_tLoadedWord = nil
	end
end

function loginLoadingBar.create()
	if instance then 
		return
	end

	instance = GUIReader:shareReader():widgetFromJsonFile("test/login_loading_bar.json")
	

	local panel_img_words = getConvertChildByName(instance,"panel_img_words")
	panel_img_words:setVisible(true)

	m_tLoadedWord = {}
	local img_word = nil
	for i = 1 ,16 do 
		img_word = getConvertChildByName(panel_img_words,"word_" .. i)
		img_word:setVisible(false)
		m_tLoadedWord[i] = false
	end



	local patch_percent = getConvertChildByName(instance,"patch_percent")
	patch_percent:setVisible(false)
	local img_patch_name = getConvertChildByName(instance,"img_patch_name")
	img_patch_name:setVisible(false)
	local patch_name = getConvertChildByName(instance,"patch_name")
	patch_name:setVisible(false)

	local main_panel = getConvertChildByName(instance,"main_panel")
	local loading_bar_line = getConvertChildByName(main_panel,"loading_bar_line")
	loading_bar_line:setPercent(0)
	local img_flag = getConvertChildByName(loading_bar_line,"img_flag")
	img_flag:setPositionX( - loading_bar_line:getContentSize().width/2 )
	local img_flag_2 = getConvertChildByName(loading_bar_line,"img_flag_2")
	img_flag_2:setPositionX( - loading_bar_line:getContentSize().width/2 + 10 )
	local action = animation.sequence({CCFadeOut:create(0.5),CCFadeIn:create(0.5)})
	img_flag:runAction(CCRepeatForever:create(action))

	local loading_bar_loaded = getConvertChildByName(loading_bar_line,"loading_bar_loaded")
	loading_bar_loaded:setPositionX(0)
	loading_bar_loaded:setPercent(0)
	local loading_bar_unload = getConvertChildByName(loading_bar_line,"loading_bar_unload")
	loading_bar_unload:setPositionX(0)

	word_percent_begin = (loading_bar_line:getContentSize().width - loading_bar_loaded:getContentSize().width)/loading_bar_line:getContentSize().width
	word_percent_begin = word_percent_begin/2

	word_percent_end = word_percent_begin + loading_bar_loaded:getContentSize().width/loading_bar_line:getContentSize().width

	word_percent_begin = word_percent_begin * 100
	word_percent_end = word_percent_end * 100


	local img_tips = getConvertChildByName(instance,"img_tips")
	local label_tips = getConvertChildByName(img_tips,"label_tips")
	local indx_tab = {}
	for k,v in pairs(languageBeforeLogin.game_tips) do 
		table.insert(indx_tab,k)
	end
	math.randomseed(os.time())  

	local indx = math.random(1,#indx_tab)
	label_tips:setText(languageBeforeLogin.game_tips[indx])
	return instance
end


function loginLoadingBar.setPercent(percent)
	if not instance then return end
	local main_panel = getConvertChildByName(instance,"main_panel")
	local loading_bar_line = getConvertChildByName(main_panel,"loading_bar_line")
	loading_bar_line:setPercent(percent)

	local img_flag = getConvertChildByName(loading_bar_line,"img_flag")
	local posX = - loading_bar_line:getContentSize().width/2 + percent * loading_bar_line:getContentSize().width / 100
	img_flag:setPositionX( posX + 30 )

	local img_flag_2 = getConvertChildByName(loading_bar_line,"img_flag_2")
	img_flag_2:setPositionX( posX + 40 )
	if percent > word_percent_begin then 
		local loading_bar_loaded = getConvertChildByName(loading_bar_line,"loading_bar_loaded")
		local wordPercent = 0

		wordPercent = (percent - word_percent_begin) * 100/(word_percent_end -word_percent_begin)
		if wordPercent > 100 then wordPercent = 100 end
		loading_bar_loaded:setPercent(wordPercent)


		local img_word = nil
		
		local panel_img_words = getConvertChildByName(instance,"panel_img_words")
		local temp_w = panel_img_words:getContentSize().width * wordPercent / 100
		for i = 1,16 do 
			img_word = getConvertChildByName(panel_img_words,"word_" .. i)
			if (img_word:getPositionX() < temp_w) and (m_tLoadedWord[i] == false) then 
				img_word:setVisible(true)
				m_tLoadedWord[i] = true
				
				local fadingKey = i 
				local img_word = getConvertChildByName(panel_img_words,"word_" .. fadingKey)
				local action = animation.sequence({CCFadeIn:create(1),CCFadeOut:create(1)})
				img_word:runAction(action)
			end
		end
	end

end


local function offsetPatchInfoPos(patch_name,patch_percent)
	if not instance then return end
	local img_patch_name = getConvertChildByName(instance,"img_patch_name")

	
	
	if patch_name and patch_percent and  patch_name:isVisible() and patch_percent:isVisible() then 
		patch_percent:setPositionY(85)
		patch_name:setPositionY(55)
		img_patch_name:setPositionY(55)
	else
		if patch_percent then 
			patch_percent:setPositionY(70)
		end
		

		if patch_name then 
			patch_name:setPositionY(70)
			img_patch_name:setPositionY(70)
		end
	end

end

-- 正在更新哪个包
function loginLoadingBar.setPatchName(nameStr,percent)
	if not instance then return end
	if not patch_name then 
		patch_name = getConvertChildByName(instance,"patch_name")
		patch_name:setVisible(true)
		local img_patch_name = getConvertChildByName(instance,"img_patch_name")
		img_patch_name:setVisible(true)
	end

	if percent then
		patch_name:setText(languageBeforeLogin["loading_res_tips"]..math.floor(percent).."%")
	else
		patch_name:setText(nameStr)
	end

	offsetPatchInfoPos(patch_name,patch_percent)
end

function loginLoadingBar.setPatchPercent(pacthPercentStr)
	if not instance then return end
	if not patch_percent then 
		patch_percent = getConvertChildByName(instance,"patch_percent")
		patch_percent:setVisible(true)
	end
	patch_percent:setText(pacthPercentStr)
	offsetPatchInfoPos(patch_name,patch_percent)
end

return loginLoadingBar